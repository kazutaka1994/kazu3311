terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "terraform-state-file-bucket-031728636747"
    region  = "ap-northeast-1"
    key     = "app/cost-notification.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}