####Glue retraining Job IAM role##########

resource "aws_iam_role" "iam_for_glue_retraining_job_role" {
  name = "${var.model_name}-retraining-job-glue-iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "glue.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}


resource "aws_iam_policy" "retraining_glue_policy" {
  name   = "${var.model_name}-retraining-glue-policy"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3BucketsAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.data_location_s3}",
                "arn:aws:s3:::${var.data_location_s3}/*",
                "arn:aws:s3:::${var.config_bucket_id}/*",
            ]
        },
        {
          "Sid": "AllowAccessToKey",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt", 
            "kms:GenerateDataKey"
          ],
          "Resource": "arn:aws:kms:${var.region}:${var.account_id}:key/*"
        }
    ]
}
EOT
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "AWSGlueServiceRole" {
  role       = aws_iam_role.iam_for_glue_retraining_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "retraining_glue_policy_attachment" {
  role       = aws_iam_role.iam_for_glue_retraining_job_role.name
  policy_arn = aws_iam_policy.retraining_glue_policy.arn
}

resource "aws_iam_role_policy_attachment" "AWSGlueConsoleFullAccess" {
  role       = aws_iam_role.iam_for_glue_retraining_job_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}