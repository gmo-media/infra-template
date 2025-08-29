# ---- EKS access entry for IAM role eks-access
data "aws_iam_role" "eks-access" {
  name = "eks-access"
}

resource "aws_eks_access_entry" "eks-access" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.aws_iam_role.eks-access.arn
}

resource "aws_eks_access_policy_association" "eks-access-admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.aws_iam_role.eks-access.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
