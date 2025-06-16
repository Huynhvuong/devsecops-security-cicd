project_name = "vuonghuynh-poc"
environment  = "dev"
region       = "ap-southeast-1"
account_id   = "077890164880"

public_route53_zone_id = "Z06336933NAYKG9J0HL8"
enabled_multi_az       = "false"

vpc_cidr = "10.9.0.0/16"

private_subnets  = ["10.9.1.0/24", "10.9.2.0/24", "10.9.3.0/24"]
public_subnets   = ["10.9.4.0/24", "10.9.5.0/24", "10.9.6.0/24"]
database_subnets = ["10.9.7.0/24", "10.9.8.0/24", "10.9.9.0/24"]

vpc_azs = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

disable_high_availability_nat_gateway = true

availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

roles = {
  create_reader_writer_role = false
  kms_admin_role            = "Vault22Admin"
}

# WARNING: This variable is used to force destroy S3 bucket and all objects inside it.
s3_force_destroy = true

container_port          = "3000"
ECSAutoScaleTargetValue = "70"

domain_name = "vault22.io"

email_address = ["vuong@vault22.io"]
