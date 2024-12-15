
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

variable "trainee_name" {
  description = "train-000"
  type        = string
  default     = "train-000"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type        = map(string)
  default = {
    public  = "10.0.1.0/24"
    app     = "10.0.2.0/24"
    db      = "10.0.3.0/24"
  }
}



