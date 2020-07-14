provider "aws" {
  region     = "${var.region}"
  profile    = "${var.profile}"
  version    = "~> 2.0"
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket        = "${var.s3_tfstate_bucket_name}"
  acl           = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
}