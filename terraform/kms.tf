################################################################################
# Regional Application KMS Key
################################################################################
resource "aws_kms_key" "application_kms" {
  description         = "Application Key"
  enable_key_rotation = true
  is_enabled          = true
  key_usage           = "ENCRYPT_DECRYPT"
  policy              = data.aws_iam_policy_document.application_kms_policy.json
}

data "aws_iam_policy_document" "application_kms_policy" {
  policy_id = "${local.name_prefix}-AppKey"
  version   = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow administration of the key"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vuong_cli"]
    }
  }

  statement {
    sid    = "Enable SNS Topic Encryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "sns:Publish",
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
