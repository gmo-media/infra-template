resource "aws_iam_role" "fargate-execution" {
  name               = "fargate-execution"
  assume_role_policy = data.aws_iam_policy_document.fargate-execution-assume.json
}

resource "aws_iam_role_policy_attachment" "fargate-execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate-execution.name
}

data "aws_iam_policy_document" "fargate-execution-assume" {
  source_policy_documents = []
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}
