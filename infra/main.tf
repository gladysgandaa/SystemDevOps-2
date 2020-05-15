provider "aws" {
  version = "~> 2.23"
  region  = "us-east-1"
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "Security Group"
  description = "Allow SSH and http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "database from ec2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "database to ec2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "https to internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
}

# terraform {
#   backend "s3" {
#     bucket = "techtestapp-s3679839-bucket"
#     key    = "terraform.tfstate.d"
#     region = "us-east-1"
#   }
# }

# data "terraform_remote_state" "network" {
#   backend = "s3"
#   config = {
#     bucket = "terraform-state-prod"
#     key    = "network/terraform.tfstate"
#     region = "us-east-1"
#   }
# }