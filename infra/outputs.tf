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

output "deployment_instructions" {
  description = "Instructions to get the application URL"
  value       = "Run: aws ecs describe-tasks --cluster ${aws_ecs_cluster.this.name} --tasks $(aws ecs list-tasks --cluster ${aws_ecs_cluster.this.name} --service-name ${aws_ecs_service.api[\"hn-interview-app\"].name} --query 'taskArns' --output text) --query 'tasks[0].attachments[0].details[?name==\"publicIp\"].value' --output text"
}
