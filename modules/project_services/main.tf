variable "project_id" { type = string }

locals {
  services = [
    "run.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com",
    "apigateway.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "cloudapis.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "managedprometheus.googleapis.com",
    "grafana.googleapis.com"
  ]
}

resource "google_project_service" "enable" {
  for_each           = toset(local.services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
