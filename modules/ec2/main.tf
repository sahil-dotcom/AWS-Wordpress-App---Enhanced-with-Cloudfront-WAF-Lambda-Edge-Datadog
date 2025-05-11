resource "aws_instance" "wordpress" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.ec2_instance_type
  iam_instance_profile = var.iam_instance_profile

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = false
  # ebs_optimized = true
  # monitoring = true
  user_data = base64encode(local.ec2_userdata_script)

  root_block_device {
    encrypted = true
  }
  ebs_block_device {
    device_name           = "/dev/xvda"
    encrypted             = true
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = false
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name        = "${var.projectname}-ec2"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "wordpress" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.wordpress.id
  port             = 80
}