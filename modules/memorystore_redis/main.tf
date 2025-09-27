variable "name"      { type = string }
variable "region"    { type = string }
variable "tier"      { type = string, default = "STANDARD_HA" }
variable "memory_size_gb" { type = number, default = 5 }
variable "authorized_network" { type = string }

resource "google_redis_instance" "redis" {
  name                = var.name
  tier                = var.tier
  region              = var.region
  memory_size_gb      = var.memory_size_gb
  authorized_network  = var.authorized_network
  transit_encryption_mode = "SERVER_AUTHENTICATION"
}

output "host" { value = google_redis_instance.redis.host }
output "port" { value = google_redis_instance.redis.port }
