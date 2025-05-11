variable "waf_name" {
  description = "Name of the WAF ACL"
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "projectname" {
  type = string
}
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}