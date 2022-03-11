
terraform {
  #   required_version = ">= 1.0.4"

  required_providers {
    # aws = ">= 3.69"
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}
