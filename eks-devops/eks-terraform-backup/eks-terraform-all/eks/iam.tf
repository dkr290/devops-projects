# Create IAM policy document for EBS CSI driver
data "aws_iam_policy_document" "ebs_csi_driver_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteSnapshot",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DetachVolume",
      "ec2:ModifyVolume"    
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "ebs_csi_driver_policy" {
  name = "ebs-csi-driver-policy"
  role = aws_iam_role.eks_node_role.name
  policy = data.aws_iam_policy_document.ebs_csi_driver_policy.json
}
data "aws_iam_policy_document" "efs_csi_driver_policy" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "elasticfilesystem:CreateAccessPoint",
      "elasticfilesystem:DeleteAccessPoint",
      "elasticfilesystem:TagResource",
      "ec2:DescribeAvailabilityZones",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:CreateMountTarget",
      "elasticfilesystem:DeleteMountTarget"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}
resource "aws_iam_role_policy" "efs_csi_driver_policy" {
  name        = "efs-csi-driver-policy"
  role = aws_iam_role.eks_node_role.name
  policy      = data.aws_iam_policy_document.efs_csi_driver_policy.json
}
