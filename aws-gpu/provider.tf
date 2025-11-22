terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Use us-east-1 - CONSISTENTLY CHEAPEST
provider "aws" {
  region = "us-east-1"
}

