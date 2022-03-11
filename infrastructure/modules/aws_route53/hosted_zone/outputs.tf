
output "zone_id" {
  description = "Id for the created route53 zone."
  value       = aws_route53_zone.this.zone_id
}

output "nameservers" {
  description = "name_servers - A list of name servers in associated (or default) delegation set. Find more about delegation sets in AWS docs."
  value       = aws_route53_zone.this.name_servers
}
