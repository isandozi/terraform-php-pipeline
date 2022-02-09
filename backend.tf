provider "aws" {
  region = var.region
}

terraform {
  required_version = "1.0.8"
}

data "aws_availability_zones" "modetrans_availability_zones" {
  exclude_names = ["us-west-2d"]
}
