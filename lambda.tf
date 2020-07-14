/*
Terraform code to configure Lambda resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/

#---------------------------------------------------
# Function for Transfering Streaming Data to Kinesis (Prescription)
#---------------------------------------------------
# Archive
data "archive_file" "lambda_transfer_ddb_streaming_data" {
  type        = "zip"
  source_dir  = "lambda/lambda_transfer_ddb_streaming_data/"
  output_path = "lambda/lambda_transfer_ddb_streaming_data/lambda_transfer_ddb_streaming_data.zip"
}

# Function
resource "aws_lambda_function" "lambda_transfer_ddb_streaming_data_prescription" {
  function_name = "lambda_${var.env}_transfer_ddb_streaming_data_prescription"

  handler          = "lambda.lambda_handler"
  filename         = "${data.archive_file.lambda_transfer_ddb_streaming_data.output_path}"
  runtime          = "python3.8"
  timeout          = 60
  role             = "${aws_iam_role.lambda-role.arn}"
  source_code_hash = "${data.archive_file.lambda_transfer_ddb_streaming_data.output_base64sha256}"

  environment {
    variables = {
      DeliveryStreamName = "firehose-${var.env}-prescription"
    }
  }

  tags = {
    project = "kamikaze2"
  }
}

#---------------------------------------------------
# Function for Transform Data (Prescription)
#---------------------------------------------------
# Archive
data "archive_file" "lambda_transform_firehose_data_prescription" {
  type        = "zip"
  source_dir  = "lambda/lambda_transform_firehose_data/prescription/"
  output_path = "lambda/lambda_transform_firehose_data/prescription/lambda_transform_firehose_data_prescription.zip"
}

# Function
resource "aws_lambda_function" "lambda_transform_firehose_data_prescription" {
  function_name = "lambda_${var.env}_transform_firehose_data_prescription"

  handler          = "lambda.lambda_handler"
  filename         = "${data.archive_file.lambda_transform_firehose_data_prescription.output_path}"
  runtime          = "python3.8"
  timeout          = 60
  role             = "${aws_iam_role.lambda-role.arn}"
  source_code_hash = "${data.archive_file.lambda_transform_firehose_data_prescription.output_base64sha256}"

  environment {
    variables = {
      DeliveryStreamName = "firehose-${var.env}-prescription"
    }
  }

  tags = {
    project = "kamikaze2"
  }
}