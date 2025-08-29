# Custom policy is required for IPv6 clusters
# https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy
resource "aws_iam_role" "eks-cni-ipv6" {
  name               = "eks-cni-ipv6"
  assume_role_policy = data.aws_iam_policy_document.eks-cni-ipv6-assume-role.json
}

data "aws_iam_policy_document" "eks-cni-ipv6-assume-role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

resource "aws_iam_role_policy_attachment" "eks-cni-ipv6" {
  role       = aws_iam_role.eks-cni-ipv6.name
  policy_arn = aws_iam_policy.eks-cni-ipv6.arn
}

resource "aws_iam_policy" "eks-cni-ipv6" {
  name   = "eks-cni-ipv6"
  policy = data.aws_iam_policy_document.eks-cni-ipv6.json
}

data "aws_iam_policy_document" "eks-cni-ipv6" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }
}
