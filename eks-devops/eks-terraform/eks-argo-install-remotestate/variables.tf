variable "aws_region" {
  description = "AWS region"
  default     = "eu-north-1"
  type        = string
}
variable "enable_alb" {
  description = "Enable or diosable alb"
  type        = string
  default     = "true"

}
variable "argocd_service" {
  description = "The backend service of argocd"
  type        = string
  default     = "argocd-server"
}



