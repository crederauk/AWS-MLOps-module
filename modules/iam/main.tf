resource "aws_iam_role" "sagemaker_role" {
  name               = "${var.model_name}-sagemaker-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "sagemaker.amazonaws.com",
          "lambda.amazonaws.com", 
          "states.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}


resource "aws_iam_policy" "sagemaker_policy" {
  name   = "${var.model_name}-sagemaker-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
	{
            "Effect": "Allow",
            "Action": "sagemaker:*",
            "Resource": "arn:aws:sagemaker:${var.region}:${var.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*"
            ]
        },
	      {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket", 
                "s3:GetBucketLocation", 
                "s3:CreateBucket"
            ],
            "Resource": [
                "arn:aws:s3:::streaming-data-platform-ml-data",
                "arn:aws:s3:::streaming-data-platform-ml-data/*",
                "arn:aws:s3:::${var.model_name}-model",
                "arn:aws:s3:::${var.model_name}-model/*",
                "arn:aws:s3:::${var.model_name}-config-bucket",
                "arn:aws:s3:::${var.model_name}-config-bucket/*"
            ]
        }, 
        {
          "Sid": "StateFunctions", 
          "Effect": "Allow",
          "Action": [
            "states:*", 
            "events:PutTargets",
            "events:PutRule",
            "events:DescribeRule",
            "events:DeleteRule",
            "events:DisableRule",
            "events:EnableRule",
            "events:ListRules"
          ],
          "Resource": "*"
        },
        {
          "Sid": "AllowPassRole",
          "Action": ["iam:GetRole","iam:PassRole"],
          "Effect": "Allow",
          "Resource": "arn:aws:iam::${var.account_id}:role/*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": [
                "sagemaker.amazonaws.com", 
                "states.amazonaws.com"
              ]
            }
          }
        },
        {
          "Sid": "AllowDescribeLogStreams",
          "Effect": "Allow",
          "Action": "logs:DescribeLogStreams",
          "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/sagemaker/TrainingJobs:log-stream:*"
        },
        {
          "Sid": "AllowGetLogEvents",
          "Effect": "Allow",
          "Action": "logs:GetLogEvents",
          "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/sagemaker/TrainingJobs:log-stream:*"
        },
        {
          "Sid": "AllowAccessToKey",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt", 
            "kms:GenerateDataKey", 
            "kms:ReEncrypt*", 
            "kms:Encrypt", 
            "kms:DescribeKey"
          ],
          "Resource": "arn:aws:kms:${var.region}:${var.account_id}:key/*"
        }
    ]
}
EOF
  tags   = var.tags
}


resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}



resource "aws_iam_role_policy_attachment" "sagemaker_role_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
    "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  ])

  role       = aws_iam_role.sagemaker_role.name
  policy_arn = each.value
}


resource "aws_iam_role" "query_training_status_role" {
  name               = "${var.model_name}-query_training_status-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}



resource "aws_iam_policy" "query_training_status_policy" {
  name   = "${var.model_name}-query_training_status-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": "lambda:*",
          "Resource": "*"
        }
    ]
}
EOF
  tags   = var.tags
}


resource "aws_iam_role_policy_attachment" "query_training_status-policy_attachment" {
  role       = aws_iam_role.query_training_status_role.name
  policy_arn = aws_iam_policy.query_training_status_policy.arn
}


resource "aws_iam_role_policy_attachment" "prebuilt-policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSageMakerReadOnly",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ])

  role       = aws_iam_role.query_training_status_role.name
  policy_arn = each.value
}
