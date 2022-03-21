output "eventbridge_bus_name" {
  description = "The EventBridge Bus Name"
  value       = var.bus_name
}

output "eventbridge_bus_arn" {
  description = "The EventBridge Bus Arn"
  value       = try(aws_cloudwatch_event_bus.event_bus.arn, "")
}
