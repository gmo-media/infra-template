# https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md#set-up-driver-permissions
resource "aws_eks_pod_identity_association" "ebs-csi" {
  cluster_name    = module.eks.cluster_name
  role_arn        = aws_iam_role.ebs-csi.arn
  namespace       = "aws-ebs-csi-driver"
  service_account = "ebs-csi-controller-sa"
}
