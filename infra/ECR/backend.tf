terraform {
  backend "s3" {
    bucket = "devops-assessment-tf"
    region = "ap-southeast-1"
  }
}
