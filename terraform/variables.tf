locals {
  name_prefix = "vuonghuynh-poc-${var.environment}"
  domain_name = "${var.environment}.${var.domain_name}"
  elb_service_accounts = {
    eu-west-1      = "156460612806"
    ap-southeast-1 = "114774131450"
  }
  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

variable "workspace_iam_roles" {
  default = {
    dev = "arn:aws:iam::077890164880:role/vuonghuynh-poc-terraform-deploy-role"
  }
}

variable "EXTERNAL_ID" {}
// Usage: export TF_VAR_EXTERNAL_ID="value"
// Ref: https://developer.hashicorp.com/terraform/language/values/variables#environment-variables

################################################################################
# Environment Variables
################################################################################
variable "project_name" {
  description = "Name of Project"
  type        = string
  default     = "vault22"
}

variable "environment" {
  description = "Name of Environment"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "public_route53_zone_id" {
  description = "Public Route53 Zone ID"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_id" {
  description = "AWS Account"
  type        = string
}

variable "roles" {
  description = "Roles Config"
  type        = map(string)
}

# WARNING: This variable is used to force destroy S3 bucket and all objects inside it.
variable "s3_force_destroy" {
  type    = bool
  default = false
}

variable "secure_container_port" {
  description = "Secure container port"
  type        = number
  default     = 443
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "enabled_stickiness" {
  type    = bool
  default = false
}

variable "ECSAutoScaleTargetValue" {
  description = "CPU ECS AutoScale Target Value"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "VPC cidr block."
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["af-south-1a", "af-south-1b"]
}

variable "public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["172.25.1.0/24", "172.25.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["172.25.3/24", "172.25.4.0/24"]
}

variable "database_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["172.25.5/24", "172.25.6.0/24"]
}

variable "disable_high_availability_nat_gateway" {
  description = "Disable HA for NAT gateway"
  type        = bool
  default     = false
}

variable "email_address" {
  type        = list(string)
  description = "List of subscription emails."
}

variable "availability_zones" {
  description = "Availability Zones for VPC"
  type        = list(string)
}


variable "enabled_multi_az" {
  description = "Is enable Multi AZ"
  type        = bool
}

variable "ecs_max_capacity" {
  description = "Max ECS capacity"
  type        = number
  default     = 2
}

variable "ecs_min_capacity" {
  description = "Min ECS capacity"
  type        = number
  default     = 1
}





