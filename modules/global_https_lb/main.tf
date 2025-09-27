variable "certificate_domains" { type = list(string) }
variable "cloud_run_service" { type = string }
variable "cloud_run_region"  { type = string }

resource "google_compute_managed_ssl_certificate" "cert" {
  name = "lb-cert"
  managed { domains = var.certificate_domains }
}

resource "google_compute_region_network_endpoint_group" "srvless_neg" {
  name                  = "cr-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.cloud_run_region
  cloud_run {
    service = var.cloud_run_service
  }
}

resource "google_compute_backend_service" "be" {
  name                  = "be-serverless"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.srvless_neg.id
  }
}

resource "google_compute_url_map" "map" {
  name            = "url-map"
  default_service = google_compute_backend_service.be.id
}

resource "google_compute_target_https_proxy" "proxy" {
  name             = "https-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
  url_map          = google_compute_url_map.map.id
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "fr-https"
  target     = google_compute_target_https_proxy.proxy.id
  port_range = "443"
}
