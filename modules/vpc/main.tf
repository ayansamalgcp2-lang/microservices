variable "project_id"  { type = string }
variable "network_name"{ type = string }
variable "subnets" {
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
  }))
}

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "subs" {
  for_each                  = { for s in var.subnets : s.name => s }
  name                      = each.value.name
  ip_cidr_range             = each.value.ip_cidr_range
  network                   = google_compute_network.vpc.id
  region                    = each.value.region
  private_ip_google_access  = true
}
