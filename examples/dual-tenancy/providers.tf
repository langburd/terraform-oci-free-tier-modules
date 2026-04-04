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
  alias               = "tenancy1"
  config_file_profile = var.profile1
}

provider "oci" {
  alias               = "tenancy2"
  config_file_profile = var.profile2
}
