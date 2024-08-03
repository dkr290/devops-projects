resource "aws_ecr_repository" "kofee_ecr" {
  name                 = "kofee_shop"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "Kofee Shop"
  }
}
