terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
    env = {
      source  = "tchupp/env"
      version = "~> 0.0.2"
    }
  }
}

provider "env" {}

data "env_variable" "profile1" {
  name = "OCI_CLI_PROFILE_1"
}

data "env_variable" "profile2" {
  name = "OCI_CLI_PROFILE_2"
}

provider "oci" {
  alias               = "tenancy1"
  config_file_profile = data.env_variable.profile1.value
}

provider "oci" {
  alias               = "tenancy2"
  config_file_profile = data.env_variable.profile2.value
}
