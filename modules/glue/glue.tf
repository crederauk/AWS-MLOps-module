#Upload retraining_job.py to s3
resource "aws_s3_object" "retraining_job_script" {
  bucket = var.config_bucket_id
  key    = "glue_scripts/retraining_job.py"
  source = "${path.module}/glue_jobs/retraining_job.py"
  etag   = filemd5("${path.module}/glue_jobs/retraining_job.py")
  tags   = var.tags
}

#####Retraining Glue job#####

resource "aws_glue_job" "retraining_glue_job" {
  name     = "${var.model_name}-retraining-glue-job"
  role_arn = aws_iam_role.iam_for_glue_retraining_job_role.arn

  command {
    name = "pythonshell"
    script_location = "s3://${var.config_bucket_id}/glue_scripts/retraining_job.py"
    python_version = "3"
  }

  max_capacity = "1"

  default_arguments = {
    "--enable-metrics"      = "true"
    "--data_location_s3"    = var.data_location_s3
    "--job-bookmark-option" = "job-bookmark-enable"
    "--additional-python-modules" = "pycaret==3.3.2,python-dotenv==1.0.1,ydata-profiling==4.10.0,shap==0.45.1,stepfunctions==2.3.0,s3fs==0.4.2"
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