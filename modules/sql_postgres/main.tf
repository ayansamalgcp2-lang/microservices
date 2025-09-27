variable "project_id" { type = string }
variable "region"     { type = string }
variable "network"    { type = string }
variable "db_name"    { type = string }
variable "db_version" { type = string, default = "POSTGRES_15" }
variable "tier"       { type = string, default = "db-custom-2-7680" }
variable "disk_size"  { type = number, default = 50 }

resource "google_sql_database_instance" "pg" {
  name             = "${var.db_name}-pg"
  project          = var.project_id
  region           = var.region
  database_version = var.db_version

  settings {
    tier       = var.tier
    disk_size  = var.disk_size
    availability_type = "REGIONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
      require_ssl     = true
    }
    backup_configuration { enabled = true, point_in_time_recovery_enabled = true }
    maintenance_window { day = 7, hour = 3 }
  }
}

resource "random_password" "db" {
  length  = 24
  special = true
}

resource "google_sql_user" "app" {
  instance = google_sql_database_instance.pg.name
  name     = "appuser"
  password = random_password.db.result
}

resource "google_sql_database" "appdb" {
  name     = var.db_name
  instance = google_sql_database_instance.pg.name
}

output "private_ip" { value = google_sql_database_instance.pg.private_ip_address }
output "db_user"    { value = google_sql_user.app.name }
output "db_name"    { value = google_sql_database.appdb.name }
