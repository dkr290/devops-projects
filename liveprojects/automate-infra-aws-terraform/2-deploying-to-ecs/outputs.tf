output "ecr_id" {
  value       = aws_ecr_repository.kofee_ecr.id
  description = "ecr id"
}


output "ecr_url" {
  value       = aws_ecr_repository.kofee_ecr.repository_url
  description = "repository url"
}
