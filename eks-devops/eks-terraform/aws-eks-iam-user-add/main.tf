resource "aws_iam_user" "admin-user" {

  name = "eksadmin1"
  path = "/"

  force_destroy = true
  tags          = local.common_tags

}
resource "aws_iam_user_policy_attachment" "eksadmin1-user" {
  user       = aws_iam_user.admin-user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

## adding the basic user 
resource "aws_iam_user" "basic-user" {

  name = "eksadmin2"
  path = "/"

  force_destroy = true
  tags          = local.common_tags

}
resource "aws_iam_user_policy" "basic-user-policy" {
  name = "${data.aws_eks_cluster.cluster}-eks-full-access-policy"
  user = aws_iam_user.basic-user.name
  policy = jsondecode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "basic-user-attchment" {
  user       = aws_iam_user.basic-user.name
  policy_arn = aws_iam_user_policy.basic-user-policy.arn

}



