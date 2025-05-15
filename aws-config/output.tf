output "alb_dns_name" {
  description = "access address"
  value       = aws_lb.main.dns_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.main.name
}