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
  alias               = "profile1"
  config_file_profile = "profile1"
}

provider "oci" {
  alias               = "profile2"
  config_file_profile = "profile2"
}
