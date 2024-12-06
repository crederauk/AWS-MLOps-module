#########################################
# Sagemaker
#########################################

variable "sagemaker_execution_role_arn" {}

variable "tags" {}

variable "data_bucket_id" {}

variable "model_target_variable" {}

variable "config_bucket_id" {}

variable "algorithm_choice" {}

variable "endpoint_name" {}

variable "model_name" {}

variable "sagemaker_instance_type" {}

variable "model_instance_count" {}

variable "ecr_repo_uri" {}

variable "tuning_metric" {}