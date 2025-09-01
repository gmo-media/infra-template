# ---- IAM Role
resource "aws_iam_role" "eks-opencost" {
  name               = "eks-opencost"
  assume_role_policy = data.aws_iam_policy_document.eks-opencost.json
}

data "aws_iam_policy_document" "eks-opencost" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

resource "aws_iam_role_policy_attachment" "eks-opencost-spot-datafeed-read" {
  role       = aws_iam_role.eks-opencost.name
  policy_arn = aws_iam_policy.spot-datafeed-read.arn
}

# ---- IAM Policy for reading datafeed bucket
resource "aws_iam_policy" "spot-datafeed-read" {
  name   = "spot-datafeed-read"
  policy = data.aws_iam_policy_document.spot-datafeed-read.json
}

data "aws_iam_policy_document" "spot-datafeed-read" {
  # https://www.opencost.io/docs/configuration/aws
  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:HeadBucket",
      "s3:HeadObject",
      "s3:List*",
      "s3:Get*",
    ]
    resources = [
      aws_s3_bucket.spot-datafeed.arn,
      "${aws_s3_bucket.spot-datafeed.arn}/*",
    ]
  }
}

# ---- Datafeed Bucket
resource "aws_s3_bucket" "spot-datafeed" {
  bucket_prefix = "spot-datafeed-"
}

resource "aws_s3_bucket_ownership_controls" "spot-datafeed" {
  bucket = aws_s3_bucket.spot-datafeed.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "spot-datafeed" {
  bucket = aws_s3_bucket.spot-datafeed.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.spot-datafeed]
}

resource "aws_s3_bucket_lifecycle_configuration" "spot-datafeed-delete-old" {
  bucket                                 = aws_s3_bucket.spot-datafeed.id
  transition_default_minimum_object_size = "varies_by_storage_class"

  rule {
    id = "delete-old-objects"
    filter {
      prefix = "datafeed/"
    }
    expiration {
      days = 7
    }
    status = "Enabled"
  }
}

# NOTE: We can specify only one aws_spot_datafeed_subscription per account
resource "aws_spot_datafeed_subscription" "spot-datafeed" {
  bucket = aws_s3_bucket.spot-datafeed.id
  prefix = "datafeed"

  depends_on = [aws_s3_bucket_acl.spot-datafeed]
}
