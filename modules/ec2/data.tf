data "aws_db_instance" "rds_instance" {
  db_instance_identifier = var.rds_id
}

data "aws_efs_file_system" "efs" {
  file_system_id = var.efs_id
}

data "aws_region" "current" {}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}