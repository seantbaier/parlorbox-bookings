output "fqdn" {
  description = "fqdns"
  value       = aws_route53_record.this.fqdn
}

