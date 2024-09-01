output "ebs_csi_iam_policy" {
  #value = data.http.ebs_csi_iam_policy.body
  value = data.http.ebs_csi_iam_policy.response_body
}
output "ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.ebs_csi_iam_policy.arn
}

output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM Role ARN"
  value       = aws_iam_role.ebs_csi_iam_role.arn
}


output "ebs_csi_helm_metadata" {
  description = "Metatadata for the deployed release"
  value       = helm_release.ebs_csi_driver.metadata
}
