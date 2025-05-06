variable "projectname" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "aws_region" {
  description = "REGION"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile Name for EC2"
  type        = string
}

variable "rds_id" {
  description = "The ID of the RDS instance"
  type        = string
}

variable "efs_id" {
  description = "The ID of the EFS file system"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the Secrets Manager secret for RDS password"
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
}