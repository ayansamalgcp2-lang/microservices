# Placeholder for PSC to Google APIs (restricted.googleapis.com).
# In many orgs this is standardized with DNS + routing outside of app stacks.
# Here we keep a minimal peering range reservation for Service Networking.

resource "google_compute_global_address" "psc_google_apis" {
  name          = "psc-google-apis"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "googleapis" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psc_google_apis.name]
}
