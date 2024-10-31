#Upload retraining_job.py to s3
# resource "aws_s3_object" "retraining_job_script" {
#   bucket = var.config_bucket_id
#   key    = "glue_scripts/retraining_job.py"
#   source = "${path.module}/glue_jobs/retraining_job.py"
#   etag   = filemd5("${path.module}/glue_jobs/retraining_job.py")
#   tags   = var.tags
# }

locals {
  file_path = "${path.module}/glue_jobs"
  files_to_upload = concat(tolist(fileset(local.file_path, "*.py")),
  tolist(fileset(local.file_path, "*.whl"))
  )

  bucket_name = "${var.config_bucket_id}"
}

resource "aws_s3_bucket_object" "glue_job_config_files" {
  for_each = toset(local.files_to_upload)
  bucket = local.bucket_name
  key = "glue_jobs/${each.value}"
  source = "${local.file_path}/${each.value}"
  etag = filemd5("${path.module}/glue_jobs/${each.value}")
  tags = var.tags 
}

#####Retraining Glue job#####

resource "aws_glue_job" "retraining_glue_job" {
  name     = "${var.model_name}-retraining-glue-job"
  role_arn = aws_iam_role.iam_for_glue_retraining_job_role.arn

  command {
    name = "pythonshell"
    script_location = "s3://${var.config_bucket_id}/glue_jobs/retraining_job.py"
    python_version = "3.9"
  }

  max_capacity = "1"

  default_arguments = {
    "--enable-metrics"      = "true"
    "--data_location_s3"    = var.data_location_s3
    "--job-bookmark-option" = "job-bookmark-enable"
    "--extra-py-files" = "s3://${var.config_bucket_id}/save_model_to_s3.py, s3://${var.config_bucket_id}/transform_data.py, s3://${var.config_bucket_id}/load_data.py, s3://${var.config_bucket_id}/finalize_and_save_model.py, s3://${var.config_bucket_id}/deploy_model_endpoint.py, s3://${var.config_bucket_id}/delete_sagemaker_endpoint.py, s3://${var.config_bucket_id}/glue_jobs/setup.py, s3://${var.config_bucket_id}/glue_jobs/mlops_dependencies_module-0.1-py3-none-any.whl"
    # "--additional-python-modules" = "pylint==2.17.5, pytest==7.4.0, flake8==6.0.0, boto3==1.28.24, pandas==1.5.3, requests==2.31.0, sagemaker==2.191.0, python-dotenv==1.0.0, pycaret==3.1.0, tensorflow==2.14.0, gunicorn==20.1.0, joblib==1.3.2"
  }
  tags = var.tags
}


#Retraining Glue job trigger
resource "aws_glue_trigger" "retraining_job_trigger" {
  name = "${var.model_name}_retraining_glue_job_trigger"

  schedule = var.retraining_schedule
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.retraining_glue_job.name
  }
  tags = var.tags
}