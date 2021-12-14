# Version
terraform {
  required_version = ">=1.0.0"

  # Provider
  required_providers {
    google = {
      version = "~> 3.45.0"
    }
    google-beta = {
      version = "< 4.4.0"
    }
    kubernetes = {
      version = "~> 2.0"
    }
  }
}
