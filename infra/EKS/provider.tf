provider "aws" {
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Environment = "dev"
    }
  }

}

terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.54"
    }
  }
}
