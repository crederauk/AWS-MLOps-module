locals {
  file_path = "${path.module}/data_files"
  file_to_upload = fileset(local.file_path, "*.csv"),

  bucket_name = var.data_bucket_id
}

resource "aws_s3_bucket_object" "data_files" {
  bucket   = local.bucket_name
  key      = "data_files/${each.value}"
  source   = "${local.file_path}/${each.value}"
  etag     = filemd5("${path.module}/data_files/${each.value}")
  tags     = var.tags
}