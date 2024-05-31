terraform {
  required_version = ">= 1.6.1"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.34.0"
    }
  }
}

provider "oci" {
  alias               = "PROFILE1"
  config_file_profile = "PROFILE1"
}

provider "oci" {
  alias               = "PROFILE2"
  config_file_profile = "PROFILE2"
}
