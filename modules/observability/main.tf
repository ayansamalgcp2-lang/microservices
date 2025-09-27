variable "project_id" { type = string }
variable "region"     { type = string }

resource "google_managed_grafana_instance" "grafana" {
  instance_id     = "org-grafana"
  project         = var.project_id
  region          = var.region
  grafana_version = "10.4"
}

resource "google_managed_grafana_instance_iam_member" "viewers" {
  project  = var.project_id
  region   = var.region
  instance = google_managed_grafana_instance.grafana.name
  role     = "roles/managedgrafana.viewer"
  member   = "user:you@example.com" # change to your group/user
}

output "grafana_url" {
  value = google_managed_grafana_instance.grafana.grafana_uri
}
