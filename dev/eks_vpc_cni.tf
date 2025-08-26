resource "aws_eks_pod_identity_association" "vpc-cni" {
  cluster_name    = module.eks.cluster_name
  role_arn        = aws_iam_role.eks-cni-ipv6.arn
  namespace       = "kube-system"
  service_account = "aws-node"
}
