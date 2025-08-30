module "eks" {
  source = "terraform-aws-modules/eks/aws"

  name               = local.name
  kubernetes_version = local.eks_version

  authentication_mode     = "API"
  endpoint_private_access = true
  endpoint_public_access  = true

  ip_family                = "ipv6"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  kms_key_administrators = [data.aws_iam_role.tofu-apply.arn]

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.name
  }

  # Required for addon IAM access
  enable_irsa = true
}

data "aws_iam_role" "tofu-apply" {
  name = "tofu-apply"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
  # renovate:eksAddonsFilter={"region":"ap-northeast-1","addonName":"kube-proxy"}
  addon_version = "v1.33.3-eksbuild.6"
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = module.eks.cluster_name
  addon_name   = "eks-pod-identity-agent"
  # renovate:eksAddonsFilter={"region":"ap-northeast-1","addonName":"eks-pod-identity-agent"}
  addon_version = "v1.3.8-eksbuild.2"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
  # renovate:eksAddonsFilter={"region":"ap-northeast-1","addonName":"vpc-cni"}
  addon_version = "v1.20.1-eksbuild.3"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  # renovate:eksAddonsFilter={"region":"ap-northeast-1","addonName":"coredns"}
  addon_version = "v1.12.3-eksbuild.1"

  depends_on = [aws_eks_fargate_profile.coredns]
}

# Allow VPC access for managed workloads (including fargate nodes)
resource "aws_vpc_security_group_ingress_rule" "cluster-allow-vpc-ipv4" {
  security_group_id = module.eks.cluster_primary_security_group_id
  cidr_ipv4         = module.vpc.vpc_cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "cluster-allow-vpc-ipv6" {
  security_group_id = module.eks.cluster_primary_security_group_id
  cidr_ipv6         = module.vpc.vpc_ipv6_cidr_block
  ip_protocol       = "-1"
}
