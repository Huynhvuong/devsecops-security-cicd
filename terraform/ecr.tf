module "app_ecr" {
  source                            = "terraform-aws-modules/ecr/aws"
  repository_name                   = "${local.name_prefix}-app"
  repository_read_write_access_arns = ["arn:aws:iam::${var.account_id}:role/vuonghuynh-poc-terraform-deploy-role", "arn:aws:iam::${var.account_id}:role/vault22-oidc-role"]
  create_lifecycle_policy           = true
  repository_force_delete           = true
  repository_image_tag_mutability   = "MUTABLE"
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

