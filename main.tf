module "s3" {
  source     = "./modules/s3"
  model_name = var.model_name
  tags       = var.tags
}


module "sagemaker" {
  source                       = "./modules/sagemaker"
  tags                         = var.tags
  sagemaker_execution_role_arn = module.iam.sagemaker_role_arn
  model_target_variable        = var.model_target_variable
  algorithm_choice             = var.algorithm_choice
  tuning_metric                = var.tuning_metric
  config_bucket_id             = module.s3.config_bucket_id
  data_location_s3             = var.data_location_s3
  endpoint_name                = var.endpoint_name
  model_name                   = var.model_name
  sagemaker_instance_type      = var.sagemaker_instance_type
  model_instance_count         = var.model_instance_count
  ecr_repo_uri                 = module.ecr.ecr_repo_uri
}


module "iam" {
  source     = "./modules/iam"
  tags       = var.tags
  region     = var.region
  account_id = var.account_id
  model_name = var.model_name
}


module "retraining_job" {
  count                = var.retrain_model_bool ? 1 : 0
  source               = "./modules/glue"
  model_name           = var.model_name
  tags                 = var.tags
  config_bucket_id     = module.s3.config_bucket_id
  algorithm_choice     = var.algorithm_choice
  target               = var.model_target_variable
  endpoint_name        = var.endpoint_name
  instance_type        = var.sagemaker_instance_type
  model_instance_count = var.model_instance_count
  image_uri            = module.ecr.ecr_repo_uri
  tuning_metric        = var.tuning_metric
  retraining_schedule  = var.retraining_schedule
  region               = var.region
  data_bucket_id       = module.s3.data_bucket_id
  file_name            = module.data.file_name
}


module "ecr" {
  source           = "./modules/ecr"
  pycaret_ecr_name = var.pycaret_ecr_name
}

module "data" {
  source = "./modules/data"
  data_bucket_id = var.data_bucket_id
  tags = var.tags
}
