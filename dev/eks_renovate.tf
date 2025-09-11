data "aws_iam_role" "renovate" {
  name = "renovate"
}

resource "aws_eks_pod_identity_association" "renovate" {
  cluster_name    = module.eks.cluster_name
  role_arn        = data.aws_iam_role.renovate.arn
  namespace       = "renovate"
  service_account = "renovate"
}
