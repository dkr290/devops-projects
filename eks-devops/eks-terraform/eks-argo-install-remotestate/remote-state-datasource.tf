# Terraform Remote State Datasource
data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "terraform-infrastate80" # Replace with your S3 bucket name
    key    = "dev/new-eks.tfstate"    # Path and name of the state file
    region = "eu-north-1"             # Replace with the AWS region where your bucket is located
    #dynamodb_table = "your-dynamodb-table"            # Optional: for state locking
    encrypt = true # Optional: to enable server-side encryption
  }
}

