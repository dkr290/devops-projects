## create autoscalling Full access

resource "aws_iam_role_policy_attachment" "eks-Autoscalling-Full-Access" {
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
  role       = var.eks_nodegroup_role_name
}
