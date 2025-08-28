# Created via aws-load-balancer-controller inside the cluster
# data "aws_alb" "example" {
#   arn = "arn:aws:elasticloadbalancing:ap-northeast-1:<aws-account-id>:loadbalancer/app/k8s-dev-abcdef/abcdef"
# }

# data "aws_route53_zone" "example-com" {
#   name = "example.com"
# }

locals {
  alb-hosts = [
    # Add your hosts here to connect them to ALB
    # "cd",
    # "whoami",
    # ...
  ]
}

# resource "aws_route53_record" "eks-alb" {
#   for_each = toset(local.alb-hosts)
#
#   zone_id = data.aws_route53_zone.example-com.zone_id
#   name    = each.key
#   type    = "A"
#   alias {
#     name                   = data.aws_alb.example.dns_name
#     zone_id                = data.aws_alb.example.zone_id
#     evaluate_target_health = false
#   }
# }
#
# resource "aws_route53_record" "eks-alb-v6" {
#   for_each = toset(local.alb-hosts)
#
#   zone_id = data.aws_route53_zone.example-com.zone_id
#   name    = each.key
#   type    = "AAAA"
#   alias {
#     name                   = data.aws_alb.example.dns_name
#     zone_id                = data.aws_alb.example.zone_id
#     evaluate_target_health = false
#   }
# }
