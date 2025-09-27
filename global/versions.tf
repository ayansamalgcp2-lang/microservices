terraform {
  required_version = ">= 1.7.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.43" }
    google-beta = { source = "hashicorp/google-beta", version = "~> 5.43" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}
