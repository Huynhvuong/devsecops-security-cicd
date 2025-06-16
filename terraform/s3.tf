################################################################################
# Log Bucket
################################################################################

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"

  bucket                  = "${local.name_prefix}-log-bucket-${data.aws_caller_identity.current.account_id}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    status = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "DeleteObjectsAfter6Months"
      enabled = true

      expiration = {
        days = 180
      }
      noncurrent_version_expiration = {
        days = 14
      }
    },
  ]
  force_destroy = var.s3_force_destroy
}

data "aws_iam_policy_document" "log_bucket_policy" {
  statement {
    sid       = "AllowSSLRequestsOnly"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [module.log_bucket.s3_bucket_arn, "${module.log_bucket.s3_bucket_arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  dynamic "statement" {
    for_each = { for k, v in local.elb_service_accounts : k => v if k == data.aws_region.current.name }

    content {
      sid = format("LoadBalancerAccessLogs-%s", title(statement.key))
      principals {
        type        = "AWS"
        identifiers = [format("arn:%s:iam::%s:root", data.aws_partition.current.partition, statement.value)]
      }
      effect = "Allow"
      actions = [
        "s3:PutObject",
      ]
      resources = ["${module.log_bucket.s3_bucket_arn}/lb-access-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    }
  }

  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${module.log_bucket.s3_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSLogDeliveryAclCheck"
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = [module.log_bucket.s3_bucket_arn]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = module.log_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.log_bucket_policy.json
}
