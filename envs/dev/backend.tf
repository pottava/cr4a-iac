terraform {
  backend "gcs" {
    prefix = "tfstate/dev/vpc"
  }
}
