resource "aws_iam_role" "ebs-csi" {
  name               = "aws-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.eks-pod-identity.json
}

resource "aws_iam_role_policy_attachment" "ebs-csi" {
  role       = aws_iam_role.ebs-csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
