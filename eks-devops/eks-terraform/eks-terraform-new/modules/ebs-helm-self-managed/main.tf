provider "helm" {
  kubernetes {
    host                   = var.eks_endpoint
    cluster_ca_certificate = base64decode(var.eks_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster]
      command     = "aws"
    }
  }
}
#EBS csi helm install 
resource "helm_release" "ebs_csi_driver" {
  name       = "${var.eks_cluster}-aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"


  set {
    name  = "image.repository"
    value = var.image_repo
  }
  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_csi_iam_role.arn
  }

  depends_on = [aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach]

  # Additional configuration options...
}
