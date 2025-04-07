terraform {
  required_version = ">= 1.6.4"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.15.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}
