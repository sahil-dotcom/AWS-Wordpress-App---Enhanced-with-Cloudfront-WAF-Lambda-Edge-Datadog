output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_id" {
  value = aws_db_instance.main.id
}

output "rds_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the RDS password"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}