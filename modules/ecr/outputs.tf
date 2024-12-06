output "ecr_name" {
  description = "The ECR name"
  value       = var.pycaret_ecr_name
}


output "ecr_repo_uri" {
  description = "The ECR repo URI"
  value       = "${aws_ecr_repository.mlops_pycaret_repo.repository_url}:latest"
}