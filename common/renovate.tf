resource "aws_iam_role" "renovate" {
  name               = "renovate"
  assume_role_policy = data.aws_iam_policy_document.eks-pod-identity.json
}

resource "aws_iam_role_policy_attachment" "renovate-lookup" {
  role       = aws_iam_role.renovate.name
  policy_arn = aws_iam_policy.renovate-lookup.arn
}

resource "aws_iam_policy" "renovate-lookup" {
  name   = "renovate-lookup"
  policy = data.aws_iam_policy_document.renovate-lookup.json
}

data "aws_iam_policy_document" "renovate-lookup" {
  statement {
    effect = "Allow"
    actions = [
      # https://docs.renovatebot.com/modules/datasource/aws-eks-addon/
      "eks:DescribeAddonVersions",
      # https://docs.renovatebot.com/modules/datasource/aws-rds/
      "rds:DescribeDBEngineVersions",
    ]
    resources = ["*"]
  }
}
