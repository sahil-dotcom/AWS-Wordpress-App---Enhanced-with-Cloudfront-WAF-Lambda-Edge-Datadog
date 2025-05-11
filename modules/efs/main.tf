resource "aws_efs_file_system" "main" {
  creation_token = "${var.projectname}-efs"
  encrypted      = true

  tags = {
    Name        = "${var.projectname}-efs"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = var.security_groups
}