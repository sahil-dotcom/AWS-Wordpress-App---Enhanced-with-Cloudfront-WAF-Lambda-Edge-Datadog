resource "aws_launch_template" "main" {
  name_prefix   = "${var.projectname}-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.alb_instance_type

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 10
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = var.instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_groups
  }

  user_data = base64encode(local.userdata_script)

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.projectname}-instance"
      Enivronment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = [var.target_group_arn]
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.projectname}-asg"
    propagate_at_launch = true
  }
}

