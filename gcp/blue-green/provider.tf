terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.0.0"
    }
  }
}

provider "google" {
  credentials = file("./credentials/terraform-sa.json")
  project     = "playground-s-11-3f69b3ac"
  region      = "us-west1"
  zone        = "us-west1"
}