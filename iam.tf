/*
Terraform code to configure IAM resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/


#----------------------------------------
# IAM Setting for Lambda Resource
#----------------------------------------

# Data Setting - Role for Lambda
data "aws_iam_policy_document" "lambda-role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Data Setting - Policy for Lambda
data "aws_iam_policy_document" "lambda-role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetAccessPoint",
      "s3:PutAccountPublicAccessBlock",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets",
      "s3:ListAccessPoints",
      "s3:ListJobs",
      "s3:CreateJob",
      "s3:HeadBucket",
      "firehose:*",
      
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ListRolePolicies",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }
}

# Create lambda Role Resource
resource "aws_iam_role" "lambda-role" {
  name               = "iamrole-${var.env}-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambda-role.json}"
}

resource "aws_iam_role_policy" "lambda-role_policy" {
  name   = "iampolicy-${var.env}-lambda"
  role   = "${aws_iam_role.lambda-role.id}"
  policy = "${data.aws_iam_policy_document.lambda-role_policy.json}"
}