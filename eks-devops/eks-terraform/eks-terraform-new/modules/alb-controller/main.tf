# Install AWS Load Balancer Controller using HELM

# Resource: Helm Release 
resource "helm_release" "loadbalancer_controller" {
  depends_on = [aws_iam_role.lbc_iam_role]
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  # Value changes based on your Region (Below is for us-east-1)
  set {
    name  = "image.repository"
    value = var.image_repo
    # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lbc_iam_role.arn
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_id
  }

}
## https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/
resource "kubernetes_ingress_class_v1" "ingress_class" {
  metadata {
    name = "alb-ingress-class"
    annotations = {
      #"alb.ingress.kubernetes.io/scheme"	internal | internet-facing
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
    }

  }

  spec {
    controller = "ingress.k8s.aws/alb"
  }
  depends_on = [helm_release.loadbalancer_controller]
}
