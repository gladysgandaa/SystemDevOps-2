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

resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "s3679389-bucket"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "s3 Remote Terraform State"
  }
}

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "s3679389-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "techtestapp-dynamodb-table"
  }
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "techtestapp-dynamodb-table"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
