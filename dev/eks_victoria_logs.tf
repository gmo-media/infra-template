resource "aws_s3_bucket" "victoria-logs-archive" {
  bucket = "<your-prefix>-${local.name}-victoria-logs-archive"
}

resource "aws_s3_bucket_lifecycle_configuration" "victoria-logs-archive" {
  bucket = aws_s3_bucket.victoria-logs-archive.bucket
  rule {
    status = "Enabled"
    id     = "transition-deep-archive"
    filter {
      prefix = ""
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
    transition {
      days          = 7
      storage_class = "DEEP_ARCHIVE"
    }
    expiration {
      days = 365
    }
  }
}

resource "aws_eks_pod_identity_association" "victoria-logs" {
  cluster_name    = module.eks.cluster_name
  role_arn        = aws_iam_role.victoria-logs.arn
  namespace       = "victoria-logs"
  service_account = "victoria-logs"
}

resource "aws_iam_role" "victoria-logs" {
  name               = "${local.name}-victoria-logs"
  assume_role_policy = data.aws_iam_policy_document.eks-pod-identity.json
}

resource "aws_iam_role_policy_attachment" "victoria-logs-archive" {
  role       = aws_iam_role.victoria-logs.name
  policy_arn = aws_iam_policy.victoria-logs-archive.arn
}

resource "aws_iam_policy" "victoria-logs-archive" {
  name   = "${local.name}-victoria-logs-archive"
  policy = data.aws_iam_policy_document.victoria-logs-archive.json
}

data "aws_iam_policy_document" "victoria-logs-archive" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:HeadBucket",
      "s3:HeadObject",
      "s3:CreateMultipartUpload",
      "s3:CompleteMultipartUpload",
      "s3:AbortMultipartUpload",
      "s3:UploadPart",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
    ]

    resources = [
      "${aws_s3_bucket.victoria-logs-archive.arn}",
      "${aws_s3_bucket.victoria-logs-archive.arn}/*",
    ]
  }
}
