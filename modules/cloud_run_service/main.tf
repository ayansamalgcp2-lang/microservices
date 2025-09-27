variable "name"                 { type = string }
variable "region"               { type = string }
variable "image"                { type = string }
variable "service_account"      { type = string }
variable "env"                  { type = map(string), default = {} }
variable "vpc_connector"        { type = string }
variable "ingress"              { type = string, default = "internal-and-cloud-load-balancing" }
variable "max_instances"        { type = number, default = 50 }
variable "min_instances"        { type = number, default = 0 }
variable "cpu"                  { type = string, default = "1" }
variable "memory"               { type = string, default = "512Mi" }
variable "concurrency"          { type = number, default = 80 }
variable "allow_unauthenticated"{ type = bool,  default = false }

resource "google_cloud_run_v2_service" "svc" {
  name     = var.name
  location = var.region

  template {
    service_account = var.service_account
    max_instance_request_concurrency = var.concurrency
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
    containers {
      image = var.image
      resources {
        cpu_idle = true
        limits = {
          "memory" = var.memory
          "cpu"    = var.cpu
        }
      }
      env = [
        for k, v in var.env : {
          name  = k
          value = v
        }
      ]
    }
    vpc_access {
      connector = var.vpc_connector
      egress    = "ALL_TRAFFIC"
    }
  }
  ingress = var.ingress
}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = var.region
  project  = google_cloud_run_v2_service.svc.project
  service  = google_cloud_run_v2_service.svc.name
  role     = "roles/run.invoker"
  member   = var.allow_unauthenticated ? "allUsers" : "serviceAccount:${var.service_account}"
}

output "url" {
  value = google_cloud_run_v2_service.svc.uri
}
