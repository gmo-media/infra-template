data "aws_iam_role" "fargate-execution" {
  name = "fargate-execution"
}

resource "aws_eks_fargate_profile" "coredns" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "coredns"
  pod_execution_role_arn = data.aws_iam_role.fargate-execution.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }
}

resource "aws_eks_fargate_profile" "karpenter" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "karpenter"
  pod_execution_role_arn = data.aws_iam_role.fargate-execution.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "karpenter"
  }
}
