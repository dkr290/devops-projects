provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}
data "aws_eks_cluster" "cluster" {
  name = "eks-cluster"
}
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-infrastate80"
    key    = "dev/eks.tfstate"
  region = "eu-central-1" }
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
}
resource "kubernetes_namespace" "envoy" {
  metadata {
    name = "envoy-gateway-system"
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}


resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.1.0" # Specify the desired chart version
  values = [
    "${file("argo-values.yaml")}"
  ]
  create_namespace = true

}




