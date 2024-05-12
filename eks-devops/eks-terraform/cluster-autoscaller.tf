
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "eks-cluster-autoscaler"
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
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "eks-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json
}

data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = ["${aws_iam_openid_connect_provider.eks.arn}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}



# provider "helm" {
#   kubernetes {
#     host                   = aws_eks_cluster.eks.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority.0.data)
#     token                  = aws_eks_cluster.eks.token
#   }
# }
# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   values     = [file("values.yaml")]
# }
