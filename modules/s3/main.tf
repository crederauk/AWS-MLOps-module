#Creating an S3 bucket to heep the trained model

# The model bucket will contain the model artifact
# The config-bucket is used to store ipynb files, python files and other configuration files
locals {
  file_path = "${path.module}/../../mlops_ml_models"
  files_to_upload = concat(
    tolist(fileset(local.file_path, "*.ipynb")),
    tolist(fileset(local.file_path, "*.py")),
    tolist(fileset(local.file_path, "requirements.txt"))
  )
  bucket_names = tolist(["${var.model_name}-model", "${var.model_name}-config-bucket"])
}

resource "aws_kms_key" "s3_kms_key" {
  enable_key_rotation = true
}

resource "aws_s3_bucket" "model_buckets" {
  count         = length(local.bucket_names)
  bucket        = local.bucket_names[count.index]
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access_block" {
  count                   = length(aws_s3_bucket.model_buckets)
  bucket                  = aws_s3_bucket.model_buckets[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload files to the config bucket
resource "aws_s3_object" "config_files" {
  for_each = toset(local.files_to_upload)
  bucket   = aws_s3_bucket.model_buckets[1].id
  key      = each.value
  source   = "${local.file_path}/${each.value}"
  etag     = filemd5("${local.file_path}/${each.value}")
  tags     = var.tags
}