variable "name" { type = string }
variable "region" { type = string }
variable "subnet" { type = string }
variable "min_instances" { type = number, default = 2 }
variable "max_instances" { type = number, default = 10 }
variable "machine_type"  { type = string, default = "e2-standard-4" }

resource "google_vpc_access_connector" "this" {
  name          = var.name
  region        = var.region
  subnet        = var.subnet
  min_instances = var.min_instances
  max_instances = var.max_instances
  machine_type  = var.machine_type
}

output "connector_id" {
  value = google_vpc_access_connector.this.id
}
