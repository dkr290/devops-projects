resource "aws_iam_role" "irsa_iam_role" {
  name = "${local.name}-irsa-iam-role"
  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.eks.outputs.aws_iam_oidc_connect_provider_exctract_from_arn}:sub" : "system:serviceaccount:default:irsa-demo-sa"
          }
        }

      },
    ]
  })

  tags = {
    tag-key = "${local.name}-irsa-iam-role"
  }
}



# Associate IAM Role and Policy
resource "aws_iam_role_policy_attachment" "irsa_iam_role_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.irsa_iam_role.name
}
# Create the service account 

resource "kubernetes_service_account_v1" "irsa_demo_sa" {
  metadata {
    name = "irsa-demo-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_iam_role.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.irsa_iam_role_policy_attach]
}


# Create a test job
resource "kubernetes_job_v1" "irsa_demo" {
  metadata {
    name = "irsa-demo"
  }
  spec {
    template {
      metadata {
        labels = {
          app = "irsa-demo"
        }
      }
      spec {
        service_account_name = kubernetes_service_account_v1.irsa_demo_sa.metadata.0.name
        container {
          name  = "irsa-demo"
          image = "amazon/aws-cli:latest"
          args  = ["s3", "ls"]
        }
        restart_policy = "Never"
      }
    }
  }
}

