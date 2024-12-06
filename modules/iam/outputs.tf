output "sagemaker_role_arn" {
  description = "Sagemaker role ARN"
  value       = aws_iam_role.sagemaker_role.arn
}


output "query_training_status_arn" {
  description = "Query Status Role ARN"
  value       = aws_iam_role.query_training_status_role.arn

}