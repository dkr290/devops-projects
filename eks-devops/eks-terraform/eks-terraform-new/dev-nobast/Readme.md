## example config

aws_region = "eu-north-1"
vpc_cidr_block = "10.0.0.0/16"
PublicA_CIDR = "10.0.101.0/24"
PublicB_CIDR = "10.0.102.0/24"
PublicC_CIDR = "10.0.103.0/24"
WorkersA_cidr = "10.0.1.0/24"
WorkersB_cidr = "10.0.2.0/24"
WorkersC_cidr = "10.0.3.0/24"
DbACIDR = "10.0.151.0/24"
DbBCIDR = "10.0.152.0/24"
DbCCIDR = "10.0.153.0/24"
azA = "eu-north-1a"
azB = "eu-north-1b"
azC = "eu-north-1c"
enable_vpc_network = true
eks_cluster_name = "dev_eks_cluster"
#bastion host related variables
bastion_instance_type = "t2.micro"
ssh_keypair = "eks-tf-key"
enable_bastion_host = true
ingress_from_port = "22"
ingress_to_port = "22"
#Eks variables
cluster_version = "1.31"
cluster_service_ipv4_cidr = "172.20.0.0/16"
cluster_endpoint_private_access = false
cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
environment = "dev"
node_group_name = "default-ng"
desired_size = 1
min_size = 1
max_size = 6
addons = [
{
name = "kube-proxy"
version = "v1.31.0-eksbuild.5"
},
{
name = "vpc-cni"
version = "v1.18.5-eksbuild.1"
},
{
name = "coredns"
version = "v1.11.3-eksbuild.1"
}

# {

# name = "aws-efs-csi-driver"

# version = "v2.0.6-eksbuild.1"

# }

]
ebs_csi_addon_name = "aws-ebs-csi-driver"
ebs_csi_addon_version = "v1.35.0-eksbuild.1"

## if using module for lb

alb_image_repo = "602401143452.dkr.ecr.eu-north-1.amazonaws.com/amazon/aws-load-balancer-controller"
