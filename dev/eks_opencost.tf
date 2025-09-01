data "aws_iam_role" "eks-opencost" {
  name = "eks-opencost"
}

resource "aws_eks_pod_identity_association" "eks-opencost" {
  cluster_name    = module.eks.cluster_name
  role_arn        = data.aws_iam_role.eks-opencost.arn
  namespace       = "opencost"
  service_account = "opencost"
}
