locals {




  environment = var.environment
  name        = "${var.cluster_name}-${var.environment}"

  # Extract OIDC Provider from OIDC Provider ARN
  # split to 0, 1 and taking 1 item
  aws_iam_oidc_connect_provider_exctract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.eks.arn}"), 1)

}
