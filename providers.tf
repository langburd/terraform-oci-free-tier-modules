terraform {
  required_version = ">= 1.14"

  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
