output "apigatewayv2_domain_name_configuration" {
  description = "The domain name configuration"
  value       = aws_apigatewayv2_domain_name.this[0].domain_name_configuration
}
