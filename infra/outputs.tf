output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
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
  description = "Direct URL to access the application (use the public IP from ECS service)"
  value       = "http://[ECS_TASK_PUBLIC_IP]:3000"
}
