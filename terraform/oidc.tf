resource "aws_iam_openid_connect_provider" "github" {
  count = var.project_name == "vuonghuynh-poc" ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "oidc" {
  count = var.project_name == "vuonghuynh-poc" ? 1 : 0
  name  = "vuonghuynh-poc-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github[0].arn,
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          },
          "ForAnyValue:StringLike" = {
            "token.actions.githubusercontent.com:sub" : [
              "repo:22sevengithub/vuonghuynh-poc-security-cicd:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "oidc" {
  count       = var.project_name == "vuonghuynh-poc" ? 1 : 0
  name        = "${local.name_prefix}-admin-policy"
  description = "Policy for OIDC role to allow admin access to all resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "acm:*",
          "application-autoscaling:*",
          "cloudformation:*",
          "cloudfront:*",
          "cloudwatch:*",
          "ec2:*",
          "ecr:*",
          "ecs:*",
          "elasticloadbalancing:*",
          "events:*",
          "dynamodb:*",
          "iam:*",
          "kms:*",
          "logs:*",
          "route53:*",
          "s3:*",
          "secretsmanager:*",
          "sns:*",
          "ssm:*",
          "autoscaling:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  count      = var.project_name == "vuonghuynh-poc" ? 1 : 0
  policy_arn = aws_iam_policy.oidc[0].arn
  role       = aws_iam_role.oidc[0].name
}

output "oidc" {
  value = aws_iam_role.oidc[*].arn
}
