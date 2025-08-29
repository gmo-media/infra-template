module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name
  namespace    = "karpenter"

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "karpenter-${local.name}-node"
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ECRAccess                    = data.aws_iam_policy.ecr-full-access.arn
  }

  iam_policy_use_name_prefix = false
  iam_policy_name            = "KarpenterController-${local.name}"
  iam_role_use_name_prefix   = false
  iam_role_name              = "KarpenterController-${local.name}"
  iam_role_source_assume_policy_documents = [
    # Use IRSA instead
    data.aws_iam_policy_document.karpenter-assume-role.json,
  ]

  # NOTE: Pod identities cannot be used in Fargate nodes
  # https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html
  create_pod_identity_association = false
}

data "aws_iam_policy" "ecr-full-access" {
  name = "ecr-full-access"
}

data "aws_iam_policy_document" "karpenter-assume-role" {
  statement {
    sid     = "irsa"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}
