/*
Terraform code to configure inVPC Lambda resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/

#---------------------------------------------------
# Function for Executing SQL to RDS (Prescription)
#---------------------------------------------------

# Archive
data "archive_file" "lambda_execute_sql_to_rds" {
  type        = "zip"
  source_dir  = "lambda/lambda_execute_sql_to_rds/"
  output_path = "lambda/lambda_execute_sql_to_rds/lambda_execute_sql_to_rds.zip"
}

# Function
resource "aws_lambda_function" "lambda_execute_sql_to_rds_prescription" {
  function_name = "lambda_${var.env}_execute_sql_to_rds_prescription"

  handler          = "lambda.lambda_handler"
  filename         = "${data.archive_file.lambda_execute_sql_to_rds.output_path}"
  runtime          = "python3.8"
  timeout          = 60
  role             = "${aws_iam_role.lambda-role.arn}"
  source_code_hash = "${data.archive_file.lambda_execute_sql_to_rds.output_base64sha256}"

  vpc_config {
    subnet_ids         = "${var.subnet_ids}"
    security_group_ids = "${var.security_group_ids}"
  }

  environment {
    variables = {
      DB_NAME         = "${var.db_name}"
      DB_USER         = "${var.db_user}"
      DB_PASSWORD     = "${var.db_password}"
      AURORA_ENDPOINT = "${var.aurora_endpoint}"
      TABLE_NAME      = "${var.prescription_table}"
      TABLE_SCHEMA    = "${var.prescription_schema}"
    }
  }

  tags = {
    project = "kamikaze2"
  }
}

# S3 Trigger Configuration
resource "aws_lambda_permission" "allow_bucket_prescription" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_execute_sql_to_rds_prescription.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3_bucket.arn}"
}