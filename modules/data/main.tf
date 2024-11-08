locals {
  file_path = "${path.module}/data_file"
  file_to_upload = fileset(local.file_path, "*.csv")
  
  bucket_name = var.data_bucket_id
}

resource "aws_s3_bucket_object" "data_file" {
  bucket   = local.bucket_name
  key      = "data_files/${local.file_to_upload}"
  source   = "${local.file_path}/${local.file_to_upload}"
  etag     = filemd5("${path.module}/data_file/${local.file_to_upload}")
  tags     = var.tags
}