# AWS-MLOps-module
This repo contains a terraform module with corresponding AWS resources that enable training, deploying and re-training AWS-hosted machine learning models with corresponding cloud infrastructure.

## Warning
This repo is a basic template for MLOps resources on AWS. Please apply appropriate security enhancements for your project in production.


## Example Usage

 ```
 module "mlops" {
  source                          = "github.com/konradbachusz/AWS-MLOps-module?ref=<module_version>"
  model_name                      = "test-model"
  sagemaker_image_repository_name = "sagemaker-xgboost"
  vpc_id                          = var.my_vpc
  subnet_ids                      = var.my_subnets
  endpoint_instance_type          = "ml.t2.medium"
  retrain_model_bool              = true
  retraining_schedule             = "cron(0 8 1 * ? *)"
  data_location_s3                = "test_bucket"
  account_id                      = var.account_id
  model_target_variable           = "test_target_column"
  region                          = var.region
} 
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_retraining_job"></a> [retraining\_job](#module\_retraining\_job) | ./modules/glue | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ./modules/s3 | n/a |
| <a name="module_sagemaker"></a> [sagemaker](#module\_sagemaker) | ./modules/sagemaker | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_data_location_s3"></a> [data\_location\_s3](#input\_data\_location\_s3) | Location of the data in s3 bucket | `string` | n/a | yes |
| <a name="input_endpoint_instance_type"></a> [endpoint\_instance\_type](#input\_endpoint\_instance\_type) | Type of EC2 instance used for model endpoint | `string` | `""` | no |
| <a name="input_model_name"></a> [model\_name](#input\_model\_name) | Name of the Sagemaker model | `string` | `""` | no |
| <a name="input_model_target_variable"></a> [model\_target\_variable](#input\_model\_target\_variable) | The dependent variable (or 'label') that the regression model aims to predict. This should be a column name in the dataset. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS deployment region | `string` | n/a | yes |
| <a name="input_retrain_model_bool"></a> [retrain\_model\_bool](#input\_retrain\_model\_bool) | Boolean to indicate if the retraining pipeline shoud be added | `bool` | `false` | no |
| <a name="input_retraining_schedule"></a> [retraining\_schedule](#input\_retraining\_schedule) | Cron expression of the model retraing frequency | `string` | n/a | yes |
| <a name="input_sagemaker_image_repository_name"></a> [sagemaker\_image\_repository\_name](#input\_sagemaker\_image\_repository\_name) | Name of the repository, which is generally the algorithm or library. Values include blazingtext, factorization-machines, forecasting-deepar, image-classification, ipinsights, kmeans, knn, lda, linear-learner, mxnet-inference-eia, mxnet-inference, mxnet-training, ntm, object-detection, object2vec, pca, pytorch-inference-eia, pytorch-inference, pytorch-training, randomcutforest, sagemaker-scikit-learn, sagemaker-sparkml-serving, sagemaker-xgboost, semantic-segmentation, seq2seq, tensorflow-inference-eia, tensorflow-inference, tensorflow-training, huggingface-tensorflow-training, huggingface-tensorflow-inference, huggingface-pytorch-training, and huggingface-pytorch-inference. | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The VPC subnets that Studio uses for communication. | `list(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to your resources | `map` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the Amazon Virtual Private Cloud (VPC) that Studio uses for communication. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_model"></a> [model](#output\_model) | Outputs the machine learning model resource |
| <a name="output_model_endpoint"></a> [model\_endpoint](#output\_model\_endpoint) | Outputs the machine learning model endpoint resource |
<!-- END_TF_DOCS -->

