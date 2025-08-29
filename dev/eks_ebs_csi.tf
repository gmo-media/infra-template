# https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md#set-up-driver-permissions
data "aws_iam_role" "ebs-csi" {
  name = "aws-ebs-csi-driver"
}

resource "aws_eks_pod_identity_association" "ebs-csi" {
  cluster_name    = module.eks.cluster_name
  role_arn        = data.aws_iam_role.ebs-csi.arn
  namespace       = "aws-ebs-csi-driver"
  service_account = "ebs-csi-controller-sa"
}
