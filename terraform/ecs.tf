
data "aws_ssm_parameter" "container_start_timeout" {
  name = "/${var.project_name}/${var.environment}/ContainerStartTimeout"
}

data "aws_ssm_parameter" "container_stop_timeout" {
  name = "/${var.project_name}/${var.environment}/ContainerStopTimeout"
}

data "aws_ssm_parameter" "app_cpu_hard_limit" {
  name = "/${var.project_name}/${var.environment}/AppCpuHardLimit"
}

data "aws_ssm_parameter" "app_memory_hard_limit" {
  name = "/${var.project_name}/${var.environment}/AppMemoryHardLimit"
}

data "aws_ssm_parameter" "app_memory_soft_limit" {
  name = "/${var.project_name}/${var.environment}/AppMemorySoftLimit"
}

data "aws_ssm_parameter" "AppTaskCPU" {
  name = "/${var.project_name}/${var.environment}/AppTaskCPU"
}

data "aws_ssm_parameter" "AppTaskMemory" {
  name = "/${var.project_name}/${var.environment}/AppTaskMemory"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.name_prefix
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## Create ALB external
resource "aws_lb" "alb_external_microservices" {
  name                             = "${local.name_prefix}-external-alb"
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = "true"
  internal                         = false
  security_groups                  = [module.app_external_loadbalancer_sg.security_group_id]
  subnets                          = module.vpc.public_subnets
  access_logs {
    bucket  = module.log_bucket.s3_bucket_id
    prefix  = "lb-access-logs"
    enabled = true
  }
  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

resource "aws_lb_listener" "alb_external_be_listerner" {
  load_balancer_arn = aws_lb.alb_external_microservices.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.regional_primary_acm.arn
  # Rule HTTPS 443 for web
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

# Create a ECS TargetGroup for HTTP port
resource "aws_lb_target_group" "app_tg" {
  name                          = "${local.name_prefix}-app-tg"
  port                          = var.container_port
  protocol                      = "HTTP"
  vpc_id                        = module.vpc.vpc_id
  target_type                   = "ip"
  load_balancing_algorithm_type = "least_outstanding_requests"
  deregistration_delay          = 5
  stickiness {
    type    = "app_cookie"
    enabled = var.enabled_stickiness
  }
  health_check {
    path                = "/healthcheck"
    protocol            = "HTTP"
    timeout             = 20
    interval            = 60
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

resource "aws_lb_listener_rule" "app_listener_rule" {
  listener_arn = aws_lb_listener.alb_external_be_listerner.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
  condition {
    host_header {
      values = ["app-poc.${local.domain_name}"]
    }
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name_prefix}-app-taskdefinition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  cpu                      = 512
  memory                   = 1024
  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-app-container"
      image     = "${module.app_ecr.repository_url}"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
  lifecycle {
    ignore_changes = [container_definitions, cpu, memory]
  }
}

resource "aws_ecs_service" "app" {
  name                              = "${local.name_prefix}-app-service"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 60

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "${local.name_prefix}-app-container"
    container_port   = var.container_port
  }
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = ["${module.app_container_sg.security_group_id}"]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
}

################################################################################
# ECS Autoscale
################################################################################

resource "aws_appautoscaling_target" "ecs_scale_target" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scale_policy" {
  name               = "${local.name_prefix}-ecs-cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.ecs_scale_target.service_namespace
  scalable_dimension = aws_appautoscaling_target.ecs_scale_target.scalable_dimension
  resource_id        = aws_appautoscaling_target.ecs_scale_target.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.ECSAutoScaleTargetValue
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}
