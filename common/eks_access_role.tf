# ---- IAM role eks-access
resource "aws_iam_role" "eks-access" {
  name               = "eks-access"
  assume_role_policy = data.aws_iam_policy_document.eks-access-trust.json

  tags = {
    Name      = "eks-access"
    Purpose   = "Operator access for the EKS cluster"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "eks-access" {
  name   = "eks-access"
  policy = data.aws_iam_policy_document.eks-access.json
}

data "aws_iam_policy_document" "eks-access" {
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "sts:GetCallerIdentity",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "eks-access" {
  role       = aws_iam_role.eks-access.name
  policy_arn = aws_iam_policy.eks-access.arn
}

# NOTE: `aws configure sso` is only allowed with AWS Organization accounts,
# so we're using IAM Users instead here. Add access keys to your IAM Users and
# place them to ~/.aws/credentials.
#
# Add the following to ~/.aws/config.
#   [profile eks-access]
#   role_arn       = arn:aws:iam::<aws-account-id>:role/eks-access
#   source_profile = your-user-profile
#
# Then run `aws eks --region ap-northeast-1 update-kubeconfig --name dev --profile eks-access` to access cluster locally.
data "aws_iam_policy_document" "eks-access-trust" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_iam_user.example.arn,
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
