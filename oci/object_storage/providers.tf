terraform {
  required_version = ">= 1.9"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.0, < 9.0"
    }
  }
}
