data "terraform_remote_state" "eks_vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-infrastate80"
    key    = "dev/vpc.tfstate"
  region = "eu-central-1" }
}
