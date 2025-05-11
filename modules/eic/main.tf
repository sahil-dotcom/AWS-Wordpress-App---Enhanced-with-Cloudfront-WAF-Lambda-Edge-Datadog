resource "aws_ec2_instance_connect_endpoint" "main" {
  subnet_id          = var.subnet_id
  security_group_ids = var.security_groups

  tags = {
    Name        = "${var.projectname}-eic"
    Environment = var.environment
  }
}