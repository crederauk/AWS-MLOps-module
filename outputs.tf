output "sagemaker_model_name" {
  description = "The name of the model"
  value       = module.sagemaker.model_name
}

output "ecr_name" {
  description = "The name of the ecr repo"
  value       = module.ecr.ecr_name
}

output "sagemaker_endpoint_name" {
  description = "Model endpoint name"
  value       = module.sagemaker.sagemaker_endpoint_name
}

output "sagemaker_algorithm_choice" {
  description = "the sagemaker algorithm choice"
  value       = module.sagemaker.sagemaker_algorithm_choice
}