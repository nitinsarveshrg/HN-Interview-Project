output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.api["hn-interview-app"].name
}

output "application_url" {
  description = "The URL to access the application"
  value       = "http://${aws_lb.app.dns_name}/hn-interview-app"
}
