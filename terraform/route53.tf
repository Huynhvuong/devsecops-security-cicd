################################################################################
# Public Hosted Zone
################################################################################
# resource "aws_route53_zone" "public_route53_zone" {
#   name = local.domain_name
# }

resource "aws_route53_record" "app_dns_record" {
  zone_id = var.public_route53_zone_id
  name    = "app-poc.${local.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb_external_microservices.dns_name
    zone_id                = aws_lb.alb_external_microservices.zone_id
    evaluate_target_health = true
  }
}


