module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 8)]

  public_subnet_ipv6_prefixes  = [0, 2]
  private_subnet_ipv6_prefixes = [1, 3]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_ipv6            = true
  create_egress_only_igw = true

  # No need of DNS64 or NAT64 for EKS
  # https://docs.aws.amazon.com/eks/latest/userguide/cni-ipv6.html
  public_subnet_enable_dns64                                    = false
  public_subnet_enable_resource_name_dns_aaaa_record_on_launch  = false
  private_subnet_enable_dns64                                   = false
  private_subnet_enable_resource_name_dns_aaaa_record_on_launch = false

  # Auto assign IPv6 address is required to use IPv6 EKS cluster
  # https://docs.aws.amazon.com/eks/latest/userguide/cni-ipv6.html
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_assign_ipv6_address_on_creation = true

  private_subnet_tags = {
    "karpenter.sh/discovery" = local.name
  }
}

# ---- Endpoints
locals {
  gateway-endpoints = toset([
    "s3",
  ])
  interface-endpoints = toset([
    # "ecr.dkr", # Enable this if you pull lots from ECR and want to avoid NAT Gateway charges
  ])
}

# -- Gateway endpoints
resource "aws_vpc_endpoint" "gateway-endpoints" {
  for_each = local.gateway-endpoints

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${local.region}.${each.key}"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    module.vpc.public_route_table_ids,
    module.vpc.private_route_table_ids,
  )

  tags = {
    Name = "${module.vpc.name}-gateway-${each.key}-endpoint"
  }
}

# -- Interface endpoints
resource "aws_vpc_endpoint" "interface-endpoints" {
  for_each = local.interface-endpoints

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${local.region}.${each.key}"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.allow-vpc.id]
  subnet_ids = concat(
    module.vpc.public_subnets,
    module.vpc.private_subnets,
  )

  tags = {
    Name = "${module.vpc.name}-interface-${each.key}-endpoint"
  }
}

# -- Security group to allow VPC connection for interface endpoints
resource "aws_security_group" "allow-vpc" {
  name        = "allow-vpc-${module.vpc.name}"
  description = "Allows inbound traffic from within VPC"
  vpc_id      = module.vpc.vpc_id

  tags = {
    "karpenter.sh/discovery" = local.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-vpc-ipv4" {
  security_group_id = aws_security_group.allow-vpc.id
  cidr_ipv4         = module.vpc.vpc_cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow-vpc-ipv6" {
  security_group_id = aws_security_group.allow-vpc.id
  cidr_ipv6         = module.vpc.vpc_ipv6_cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow-vpc-ipv4" {
  security_group_id = aws_security_group.allow-vpc.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow-vpc-ipv6" {
  security_group_id = aws_security_group.allow-vpc.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
