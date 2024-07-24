terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.59"
    }



    local = {
      source  = "hashicorp/local"
      version = "~>2.5"
    }


  }
  backend "s3" {
    bucket = "terraform-infrastate80" # Replace with your S3 bucket name
    key    = "dev/VPC-lp.tfstate"     # Path and name of the state file
    region = "eu-central-1"           # Replace with your AWS region
    #dynamodb_table = "my-terraform-locks" # DynamoDB table for locking, replace with your table name
    encrypt = true # Encrypt the state file at rest using AWS-managed keys
  }


}



#Provider Block
provider "aws" {
  region = var.region



}
