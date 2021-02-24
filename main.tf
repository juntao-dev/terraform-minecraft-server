terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

locals {
  minecraft_backup_s3_bucket_name = ""
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_iam_role" "iam_minecraft_bot_role" {
  name = "iam_minecraft_bot_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_minecraft_bot_policy" {
  name        = "iam_minecraft_bot_policy"
  path        = "/"
  description = "IAM policy for minecraft instance"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.minecraft_world_data_backup_bucket.arn}",
        "${aws_s3_bucket.minecraft_world_data_backup_bucket.arn}/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_minecraft_bot_policy_attachment" {
  role       = aws_iam_role.iam_minecraft_bot_role.name
  policy_arn = aws_iam_policy.iam_minecraft_bot_policy.arn
}

resource "aws_iam_instance_profile" "iam_minecraft_bot_instance_profile" {
  name = "iam_minecraft_bot_instance_profile"
  role = aws_iam_role.iam_minecraft_bot_role.name
}

resource "aws_s3_bucket" "minecraft_world_data_backup_bucket" {
  bucket = local.minecraft_backup_s3_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_block" {
  bucket = aws_s3_bucket.minecraft_world_data_backup_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_instance" "minecraft_server" {
  ami                         = "ami-04f77aa5970939148"
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.allow_minecraft.name
  ]
  iam_instance_profile = aws_iam_instance_profile.iam_minecraft_bot_instance_profile.name
  user_data            = templatefile("${path.module}/script.sh", { bucket_name = local.minecraft_backup_s3_bucket_name })

  tags = {
    Name = "Minecraft Server Instance"
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "allow_minecraft" {
  name        = "allow_minecraft"
  description = "Allow minecraft traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_minecraft_default_port"
  }
}

output "minecraft_server_ip" {
  value = "${aws_instance.minecraft_server.public_ip}:25565"
}

output "minecraft_backup_s3_bucket" {
  value = local.minecraft_backup_s3_bucket_name
}
