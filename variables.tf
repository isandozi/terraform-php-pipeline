variable "region" {}

variable "vpc_cidr" {
  default = {
    us-east-2 = "10.10.0.0/16"
    us-west-1 = "10.11.0.0/16"
    us-west-2 = "10.12.0.0/16"
  }
}

variable "application_name" {
  default = "modetrans-interview-task"
}

variable "application_environment" {
  default = {
    us-east-2 = "dev"
    us-west-1 = "staging"
    us-west-2 = "prod"
  }
}

variable "ec2_amis" {
  default = {
    us-east-2 = "ami-0b614a5d911900a9b"
    us-west-1 = "ami-0573b70afecda915d"
    us-west-2 = "ami-0341aeea105412b57"
  }
}
