terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.43" }
  }
}

variable "project_id"      { type = string }
variable "bucket_name"     { type = string }
variable "bucket_location" { type = string }

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "tfstate" {
  name          = var.bucket_name
  location      = var.bucket_location
  force_destroy = false

  versioning { enabled = true }
  uniform_bucket_level_access = true

  lifecycle_rule {
    action { type = "SetStorageClass"; storage_class = "ARCHIVE" }
    condition { age = 180 }
  }
}

output "bucket_name" { value = google_storage_bucket.tfstate.name }
