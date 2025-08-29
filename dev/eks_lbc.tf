# https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/
data "aws_iam_role" "eks-lbc" {
  name = "eks-lbc"
}

resource "aws_eks_pod_identity_association" "eks-lbc" {
  cluster_name    = module.eks.cluster_name
  role_arn        = data.aws_iam_role.eks-lbc.arn
  namespace       = "aws-load-balancer-controller"
  service_account = "aws-load-balancer-controller"
}
