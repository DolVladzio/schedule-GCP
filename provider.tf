##################################################################
provider "google" {
  project = local.config.project.name
  region  = local.region
}
##################################################################
terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
##################################################################