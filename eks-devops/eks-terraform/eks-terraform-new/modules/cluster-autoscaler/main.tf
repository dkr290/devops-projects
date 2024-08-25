resource "aws_iam_policy" "cluster_autoscaler_iam_policy" {
  name        = "${var.eks_cluster}-AmazonEKSClusterAutoscalerPolicy"
  description = "EKS Cluster Autoscaler Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeInstanceTypes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = ["${var.aws_iam_openid_connect_provider}"]
      type        = "Federated"
    }
  }
}
resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  name               = "${var.eks_cluster}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_iam_role_policy" {
  policy_arn = aws_iam_policy.cluster_autoscaler_iam_policy.arn
  role       = aws_iam_role.cluster_autoscaler_iam_role.name
}

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
# Install the Cluster Autoscaler using Helm
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_id
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler_iam_role.arn
  }
  set {
    name  = "extraArgs.scale-down-utilization-threshold"
    value = 0.3
  }
  depends_on = [aws_iam_role.cluster_autoscaler_iam_role]

  # Additional configuration options...
}
