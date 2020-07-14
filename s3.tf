/*
Terraform code to configure IAM resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.s3_bucket_name}"
  acl           = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
  tags = {
    project = "kamikaze2"
  }
}