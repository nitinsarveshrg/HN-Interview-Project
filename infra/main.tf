# ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = "hn-interview-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Networking
data "aws_vpc" "default" { default = true }
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Logs
resource "aws_cloudwatch_log_group" "app" {
  for_each          = { for svc in var.services : svc.name => svc }
  name              = "/ecs/${each.key}"
  retention_in_days = 7
}

# IAM
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "ecs-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "task_exec_policy" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Security groups
resource "aws_security_group" "lb" {
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "task" {
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer
resource "aws_lb" "app" {
  name               = "multi-api-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "multi-api-cluster"
}

# Services
resource "aws_lb_target_group" "api" {
  for_each    = { for svc in var.services : svc.name => svc }
  name        = "${each.key}-tg"
  port        = each.value.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_lb_listener_rule" "api" {
  for_each     = { for svc in var.services : svc.name => svc }
  listener_arn = aws_lb_listener.http.arn
  priority     = 100 + index(var.services, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/${each.key}*"]
    }
  }
}

resource "aws_ecs_task_definition" "api" {
  for_each                 = { for svc in var.services : svc.name => svc }
  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name      = each.key
      image     = "${aws_ecr_repository.app.repository_url}:${each.key}"
      essential = true
      portMappings = [
        {
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app[each.key].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = each.key
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api" {
  for_each        = { for svc in var.services : svc.name => svc }
  name            = each.key
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.api[each.key].arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.task.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api[each.key].arn
    container_name   = each.key
    container_port   = each.value.container_port
  }

  depends_on = [aws_lb_listener_rule.api]
}
