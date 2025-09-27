variable "api_id"        { type = string }
variable "region"        { type = string }
variable "openapi_spec"  { type = string }
variable "gateway_id"    { type = string }

resource "google_api_gateway_api" "api" {
  api_id = var.api_id
}

resource "google_api_gateway_api_config" "cfg" {
  api               = google_api_gateway_api.api.api_id
  api_config_id     = "${var.api_id}-cfg"
  openapi_documents {
    document {
      path     = var.openapi_spec
      contents = file(var.openapi_spec)
    }
  }
  depends_on = [google_api_gateway_api.api]
}

resource "google_api_gateway_gateway" "gw" {
  region     = var.region
  gateway_id = var.gateway_id
  api_config = google_api_gateway_api_config.cfg.id
}

output "url" {
  value = google_api_gateway_gateway.gw.default_hostname
}
