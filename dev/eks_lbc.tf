# https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/deploy/installation/
resource "aws_eks_pod_identity_association" "eks-lbc" {
  cluster_name    = module.eks.cluster_name
  role_arn        = aws_iam_role.eks-lbc.arn
  namespace       = "aws-load-balancer-controller"
  service_account = "aws-load-balancer-controller"
}
