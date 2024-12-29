
## Resousrce AWS IAM ROLE with sts assume policy
#add assume role policy 
#add iam policy
resource "aws_iam_role" "eks_admin_role" {
  name = "eks_admin_role-${local.environment}"


  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })
  inline_policy {
    name = "eks-full-access-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "iam:ListRoles",
            "eks:*",
            "ssm:GetParameter"
          ]
          Effect   = "Allow",
          Resource = "*"

        },
      ]
    })

  }

  tags = local.common_tags

}




#AWS IAM GROUP 

resource "aws_iam_group" "eksadmins_iam_group" {
  name = "eksadmins-${local.environment}"
  path = "/"
}

# AWS IAM GROUP POLICY 
resource "aws_iam_group_policy" "eksadmins_iam_group_assumerole_policy" {
  name  = "eksadmins-group-policy-${local.environment}"
  group = aws_iam_group.eksadmins_iam_group.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow",
        Sid      = "AllowAssumeOrganizationAccountRole",
        Resource = "${aws_iam_role.eks_admin_role.arn}"
      },
    ]
  })
}

# AWS IAM USER - Basic USer (no aws console access)

resource "aws_iam_user" "ekasadmin_user" {
  name          = "eksadmin3-${local.environment}"
  path          = "/"
  force_destroy = true
  tags          = local.common_tags

}
# AWS IAM Group membership 

resource "aws_iam_group_membership" "eksadmins" {
  name = "eksadmins-${local.environment}"

  users = [
    aws_iam_user.ekasadmin_user.id
  ]

  group = aws_iam_group.eksadmins_iam_group.name
}

## adding the basic user 
resource "aws_iam_user" "basic-user" {

  name = "eksadmin2"
  path = "/"

  force_destroy = true
  tags          = local.common_tags

}
resource "aws_iam_user" "admin-user" {

  name = "eksadmin1"
  path = "/"

  force_destroy = true
  tags          = local.common_tags

}

