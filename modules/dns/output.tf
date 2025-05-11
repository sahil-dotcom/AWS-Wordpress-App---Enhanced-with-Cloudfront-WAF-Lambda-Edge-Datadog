output "zone_id" {
  value = aws_route53_zone.dev.zone_id
}

output "name_servers" {
  value = aws_route53_zone.dev.name_servers
}