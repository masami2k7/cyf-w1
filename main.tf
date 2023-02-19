terraform {
  /* Establish the AWS Provider for Terraform */
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

/* Set The Region for the Provider, note is you change region you will need a different AMI ID */
provider "aws" {
  region = "eu-west-2"
}

/* Creates a variable which can be injected later into the user data script */
locals {
  vars = {
    user_data_key = var.cyf-public-key
  }
}

/* Create a new security group which allows SSH access from your local */
resource "aws_security_group" "cyf-w1-sg" {
  vpc_id = var.cyf-vpc-id
  ingress {
    cidr_blocks = [
      var.cyf-localIP
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Create the AWS instance */
resource "aws_instance" "app_server" {
  ami             = "ami-0aaa5410833273cfe"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cyf-w1-sg.id]
  key_name        = "cyf-w1" /* If you didnt create your key as per the readme with this name youll need to change it */
  user_data = base64encode(templatefile("user_data.sh", local.vars)) /* Imports the script with the variables replaced for the public key */
  tags = {
    Name = "ExampleAppServerInstance"
  }
}
