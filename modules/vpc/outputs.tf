output "vpc_self_link" { value = google_compute_network.vpc.self_link }
output "subnets" {
  value = { for k, v in google_compute_subnetwork.subs : k => {
    id      = v.id
    self_link = v.self_link
    ip_cidr_range = v.ip_cidr_range
    region  = v.region
  }}
}
