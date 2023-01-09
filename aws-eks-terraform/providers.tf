terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.20"

    }
   
  

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

 
  }

  }



#Provider Block
provider "aws" {
  region = var.aws_region



}