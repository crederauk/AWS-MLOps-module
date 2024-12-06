resource "aws_kms_key" "ecr_kms" {
  enable_key_rotation = true
}

resource "aws_ecr_repository" "mlops_pycaret_repo" {
  name                 = var.pycaret_ecr_name
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr_kms.arn
  }
}
