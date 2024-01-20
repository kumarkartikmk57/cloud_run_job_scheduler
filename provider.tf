terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }
  backend "gcs" {
    bucket  = "cosmic-descent-405605-tfstates"
    prefix  = "terraform/jobrun"
  }
}

provider "google" {
  # Configuration options
}