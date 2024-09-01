# Datasource: EBS CSI IAM Policy get from EBS GIT Repo (latest)
data "http" "ebs_csi_iam_policy" {
  url = var.iam_policy
  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}
# Resource: Create EBS CSI IAM Policy 
resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "${var.eks_cluster}-AmazonEKS_EBS_CSI_Driver_Policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  #policy = data.http.ebs_csi_iam_policy.body
  policy = data.http.ebs_csi_iam_policy.response_body
}

# Resource: Create IAM Role and associate the EBS IAM Policy to it
resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "${var.eks_cluster}-ebs-csi-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${var.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${var.aws_iam_openid_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }

      },
    ]
  })

  tags = {
    tag-key = "${var.eks_cluster}-ebs-csi-iam-role"
  }
}


# Associate EBS CSI IAM Policy to EBS CSI IAM Role
resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn
  role       = aws_iam_role.ebs_csi_iam_role.name
}
