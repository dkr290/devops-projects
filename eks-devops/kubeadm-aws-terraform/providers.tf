terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
  }

 backend "s3" {
    bucket = ""
    key    = "kubeaadm-aws-training.tfstate"
    region = "eu-central-1"
  }

}


provider "aws" {
  region = "eu-central-1"
}
