resource "aws_iam_policy" "ecr-full-access" {
  name        = "ecr-full-access"
  description = "ECR access for Karpenter nodes"
  policy      = data.aws_iam_policy_document.ecr-full-access.json
}

data "aws_iam_policy_document" "ecr-full-access" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:*",
    ]
    resources = ["*"]
  }
}

resource "aws_ecr_pull_through_cache_rule" "docker-hub" {
  ecr_repository_prefix = "docker-hub"
  upstream_registry_url = "registry-1.docker.io"
  # Secret name must have prefix "ecr-pullthroughcache/"
  # and have "username" and "accessToken" key
  credential_arn = "arn:aws:secretsmanager:ap-northeast-1:<aws-account-id>:secret:ecr-pullthroughcache/<secret-id>"
}

resource "aws_ecr_repository_creation_template" "docker-hub" {
  applied_for = ["PULL_THROUGH_CACHE"]
  prefix      = "docker-hub"

  lifecycle_policy = data.aws_ecr_lifecycle_policy_document.docker-hub.json
}

data "aws_ecr_lifecycle_policy_document" "docker-hub" {
  rule {
    priority    = 1
    description = "Expire images older than 14 days"
    selection {
      tag_status   = "any"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 14
    }
    action {
      type = "expire"
    }
  }
}
