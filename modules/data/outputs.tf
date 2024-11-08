output "file_name" {
  value = aws_s3_bucket_object.data_file.key
}