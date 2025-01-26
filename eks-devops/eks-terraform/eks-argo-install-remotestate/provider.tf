terraform {
  required_version = "~>1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-infrastate80" # Replace with your S3 bucket name
    key    = "dev/argocd-eks.tfstate" # Path and name of the state file
    region = "eu-north-1"             # Replace with your AWS region
    #dynamodb_table = "my-terraform-locks" # DynamoDB table for locking, replace with your table name
    encrypt = true # Encrypt the state file at rest using AWS-managed keys
  }
}
# get EKS cluster name using remote state datasource
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id

}
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_id
}
provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token

}
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.aws_region

}
