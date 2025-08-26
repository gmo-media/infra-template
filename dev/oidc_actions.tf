locals {
  repository  = "gmo-media/infra-template"
  main_branch = "main"
}

# ---- GitHub Actions OIDC Provider
resource "aws_iam_openid_connect_provider" "github-actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name      = "github-actions-oidc"
    ManagedBy = "Terraform"
  }
}

# ---- IAM Role for Plan (Read-Only)
resource "aws_iam_role" "tofu-plan" {
  name               = "tofu-plan"
  assume_role_policy = data.aws_iam_policy_document.tofu-plan-trust.json

  tags = {
    Name      = "tofu-plan"
    Purpose   = "Read-only access for Terraform/Tofu plan"
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy_document" "tofu-plan-trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github-actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repository}:*"] # Allow any branch
    }
  }

  # NOTE: `aws configure sso` is only allowed with AWS Organization accounts,
  # so we're using IAM Users instead here. Add access keys to your IAM Users and
  # place them to ~/.aws/credentials.
  #
  # Then add the following to ~/.aws/config, and use `aws --profile tofu-plan`.
  #   [profile tofu-plan]
  #   role_arn       = arn:aws:iam::123456789012:role/tofu-plan
  #   source_profile = your-user-profile
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_iam_role.sso-power-users.arn,
        data.aws_iam_role.sso-admin.arn,
        # Add users
        data.aws_iam_user.example.arn,
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_role" "sso-power-users" {
  name = "sso-PowerUsers"
}

data "aws_iam_role" "sso-admin" {
  name = "sso-Admin"
}

data "aws_iam_user" "example" {
  user_name = "example"
}

resource "aws_iam_role_policy_attachment" "tofu-plan-readonly" {
  role       = aws_iam_role.tofu-plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ---- IAM Role for Apply (PowerUser + IAM)
resource "aws_iam_role" "tofu-apply" {
  name               = "tofu-apply"
  assume_role_policy = data.aws_iam_policy_document.tofu-apply-trust.json

  tags = {
    Name      = "tofu-apply"
    Purpose   = "Full access for Terraform/Tofu apply"
    ManagedBy = "Terraform"
  }
}

data "aws_iam_policy_document" "tofu-apply-trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github-actions.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repository}:ref:refs/heads/${local.main_branch}"] # Allow only main branch
    }
  }
}

resource "aws_iam_role_policy_attachment" "tofu-apply-poweruser" {
  role       = aws_iam_role.tofu-apply.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "tofu-apply-iam" {
  role       = aws_iam_role.tofu-apply.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
