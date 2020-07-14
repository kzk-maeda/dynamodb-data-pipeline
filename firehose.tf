/*
Terraform code to configure Kinesis Firehose resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/

#---------------------------------------------------
# Data Firehose (Prescription)
#---------------------------------------------------

resource "aws_kinesis_firehose_delivery_stream" "firehose_stream_prescription" {
  name        = "firehose-${var.env}-presctiption"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = "${aws_iam_role.firehose-role.arn}"
    bucket_arn = "${aws_s3_bucket.s3_bucket.arn}"

    prefix = "streaming/data=prescription/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "streamingError/data=prescription/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}"

    buffer_size = 5
    buffer_interval = 300

    cloudwatch_logging_options {
      enabled = true
      log_group_name = "kamikaze_firehose_log_group"
      log_stream_name = "kamikaze_firehose_log_stream"
    }

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_transform_firehose_data_prescription.arn}:$LATEST"
        }
        parameters {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = 3
        }
        parameters {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = 60
        }

      }
    }
  }

  tags = {
    project = "kamikaze2"
  }
}