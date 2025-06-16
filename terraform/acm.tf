################################################################################
# ACM
################################################################################

resource "aws_acm_certificate" "global_primary_acm" {
  provider          = aws.aws-global
  domain_name       = local.domain_name
  validation_method = "DNS"

  # Optional: Add additional SANs if needed
  subject_alternative_names = ["*.${local.domain_name}"]
  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

resource "aws_acm_certificate_validation" "global_primary_acm" {
  provider                = aws.aws-global
  certificate_arn         = aws_acm_certificate.global_primary_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.global_primary_acm_validation : record.fqdn]
}

resource "aws_route53_record" "global_primary_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.regional_primary_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.public_route53_zone_id
}


resource "aws_acm_certificate" "global_primary_acm_investor" {
  provider          = aws.aws-global
  domain_name       = "investor.${local.domain_name}"
  validation_method = "DNS"

  # Optional: Add additional SANs if needed
  subject_alternative_names = ["*.investor.${local.domain_name}"]
  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

# resource "aws_acm_certificate_validation" "global_primary_acm_investor" {
#   provider                = aws.aws-global
#   certificate_arn         = aws_acm_certificate.global_primary_acm_investor.arn
#   validation_record_fqdns = [for record in aws_route53_record.global_primary_acm_investor_validation : record.fqdn]
# }

resource "aws_route53_record" "global_primary_acm_investor_validation" {
  provider = aws.aws-global
  for_each = {
    for dvo in aws_acm_certificate.regional_primary_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.public_route53_zone_id
}

################################################################################
# ACM Regional
resource "aws_acm_certificate" "regional_primary_acm" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  # Optional: Add additional SANs if needed
  subject_alternative_names = ["*.${local.domain_name}"]
  tags = {
    Name      = "${local.domain_name}"
    Terraform = "true"
  }
}

resource "aws_acm_certificate_validation" "regional_primary_acm" {
  certificate_arn         = aws_acm_certificate.regional_primary_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.regional_primary_acm_validation : record.fqdn]
}

resource "aws_route53_record" "regional_primary_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.regional_primary_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.public_route53_zone_id
}
