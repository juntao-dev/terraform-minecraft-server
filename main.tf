terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_instance" "minecraft_server" {
  ami                         = "ami-04f77aa5970939148"
  instance_type               = "t2.large"
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.allow_minecraft.name
  ]
  user_data = file("script.sh")

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

output "instance_ip_addr" {
  value = aws_instance.minecraft_server.public_ip
}
