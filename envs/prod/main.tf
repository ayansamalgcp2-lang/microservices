terraform {
  required_version = ">= 1.7.0"
}

locals {
  env = terraform.workspace
}

module "services" {
  source     = "../../modules/project_services"
  project_id = var.project_id
}

module "vpc" {
  source       = "../../modules/vpc"
  project_id   = var.project_id
  network_name = "${var.project_prefix}-prod-vpc"
  subnets = [
    { name = "prod-priv-a", ip_cidr_range = var.subnet_cidr_a, region = var.region },
    { name = "prod-priv-b", ip_cidr_range = var.subnet_cidr_b, region = var.region }
  ]
}

module "connector" {
  source = "../../modules/serverless_connector"
  name   = "prod-cr-conn"
  region = var.region
  subnet = module.vpc.subnets["prod-priv-a"].id
}

module "sql" {
  source     = "../../modules/sql_postgres"
  project_id = var.project_id
  region     = var.region
  network    = module.vpc.vpc_self_link
  db_name    = "${var.project_prefix}_prod"
}

module "redis" {
  source             = "../../modules/memorystore_redis"
  name               = "prod-redis"
  region             = var.region
  authorized_network = module.vpc.vpc_self_link
  memory_size_gb     = 5
}

module "iam" {
  source     = "../../modules/iam"
  project_id = var.project_id
  service_accounts = {
    "cr-orders" = {
      display_name = "Cloud Run SA for orders svc"
      roles = [
        "roles/run.invoker",
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/secretmanager.secretAccessor"
      ]
    }
    "cr-inventory" = {
      display_name = "Cloud Run SA for inventory svc"
      roles = [
        "roles/run.invoker",
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/secretmanager.secretAccessor"
      ]
    }
  }
}

module "orders_service" {
  source          = "../../modules/cloud_run_service"
  name            = "orders-prod"
  region          = var.region
  image           = var.orders_image
  service_account = "cr-orders@${var.project_id}.iam.gserviceaccount.com"
  vpc_connector   = module.connector.connector_id
  env = {
    DB_HOST   = module.sql.private_ip
    DB_NAME   = "${var.project_prefix}_prod"
    DB_USER   = "appuser"
    REDIS_HOST = module.redis.host
  }
}

module "inventory_service" {
  source          = "../../modules/cloud_run_service"
  name            = "inventory-prod"
  region          = var.region
  image           = var.inventory_image
  service_account = "cr-inventory@${var.project_id}.iam.gserviceaccount.com"
  vpc_connector   = module.connector.connector_id
  env = {
    REDIS_HOST = module.redis.host
  }
}

module "api_gw" {
  source       = "../../modules/api_gateway"
  api_id       = "api-prod"
  region       = var.region
  gateway_id   = "gw-prod"
  openapi_spec = "${path.module}/specs/orders-api.yaml"
}

module "obs" {
  source     = "../../modules/observability"
  project_id = var.project_id
  region     = var.region
}
