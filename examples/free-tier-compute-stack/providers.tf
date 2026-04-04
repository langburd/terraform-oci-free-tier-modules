terraform {
  required_version = ">= 1.6.4"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
    }
  }
}

provider "oci" {
  config_file_profile = var.oci_config_profile
}
