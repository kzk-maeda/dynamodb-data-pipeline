/*
Terraform code to configure IAM resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
  tags = {
    project = "kamikaze2"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.s3_bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda_execute_sql_to_rds_prescription.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "streaming/data=prescription"
  }

  depends_on = [aws_lambda_permission.allow_bucket_prescription]
}