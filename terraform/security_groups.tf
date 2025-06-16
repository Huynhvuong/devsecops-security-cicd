# Create a security group for load balancer and open port 443 in bound from internet
module "app_external_loadbalancer_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "${local.name_prefix}-ecs-alb-sg"
  use_name_prefix = false
  description     = "${local.name_prefix}-ecs-alb-sg"
  vpc_id          = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# Creat a security group for Containers and open in bound Container port from Load balancer security group to the Container
module "app_container_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name            = "${local.name_prefix}-container-sg"
  use_name_prefix = false
  description     = "${local.name_prefix}-container-sg"
  vpc_id          = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = module.app_external_loadbalancer_sg.security_group_id
    },
    {
      from_port                = var.secure_container_port
      to_port                  = var.secure_container_port
      protocol                 = "tcp"
      source_security_group_id = module.app_external_loadbalancer_sg.security_group_id
    },
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = var.secure_container_port
      to_port     = var.secure_container_port
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

