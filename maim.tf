/*
Terraform code to configure main provider resources

Terraform version over 12.0

@author     kzk_maeda
@copyright  2020-2021 Kakehashi. inc
@version    0.1
*/

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
  version = "~> 2.0"
}

data "aws_caller_identity" "self" {}