terraform {
  required_providers {
    google = {
      version     = "~> 3.69.0"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-paymentsense-315208"
    prefix  = "techtest/state"
  }
}
