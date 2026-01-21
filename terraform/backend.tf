terraform {
  cloud {
    organization = "SAM_J_HASHiCORP"

    workspaces {
      name = "MERN_Stack_DevOps"

    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.28.0"

    }
  }
}
provider "aws" {
  region = "ap-south-1"
}

