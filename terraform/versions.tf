terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.67.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  required_version = ">= 1.0"
}

