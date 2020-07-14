/*
Terraform code to configure S3 backend resources

Terraform version over 12.0

@author     kzk_maeda
@version    0.1
*/

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket  = "s3bucket-sandbox-kamikaze2"
    region  = "ap-northeast-1"
    key     = "tfstate/terraform.tfstate"
    encrypt = true
    profile = "kakehashi-sandbox-terraform"
  }
}
