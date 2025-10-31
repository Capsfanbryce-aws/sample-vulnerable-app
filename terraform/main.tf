# NOTE: contains intentional security test patterns for SAST/SCA/IaC scanning.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "sample-app-terraform-bucket-12345"
  acl    = "public-read"                        # Issue 1: public-read ACL
}

resource "aws_iam_policy" "app_policy" {
  name        = "app-restricted-access"
  description = "Policy with least privilege access for instances"

  # Fixed: Replaced wildcard permissions with specific required actions and resources
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::sample-app-terraform-bucket-12345",
        "arn:aws:s3:::sample-app-terraform-bucket-12345/*"
      ]
    }
  ]
}
EOF
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Security group with wide open access"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]                 # Issue 4: all ports open to the world
  }
}