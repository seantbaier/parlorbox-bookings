terraform {
  required_version = ">= 0.14.9"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}
