output "cert_arn" {
  value = aws_acm_certificate.cert.arn
}

output "validation_records" {
  description = "The DNS records used for validation"
  value       = aws_acm_certificate.cert.domain_validation_options
}