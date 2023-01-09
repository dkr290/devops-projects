terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"

    }
  }
}


#Provider Block
provider "aws" {
  region = "eu-central-1"
 


}