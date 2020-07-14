# Main Configuration
variable "region" {}
variable "env" {
  description = "enter (tst|dev|prd)"
}
variable "profile" {}
variable "s3_bucket_name" {}

variable "prescription_streaming_arn" {}

variable "db_name" {}
variable "db_user" {}
variable "db_password" {}
variable "aurora_endpoint" {}

variable "prescription_table" {}
variable "prescription_schema" {}

variable "subnet_ids" {}
variable "security_group_ids" {}
