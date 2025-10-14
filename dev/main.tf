# ---- Backend and providers

terraform {
  backend "s3" {
    bucket = "your-tfstate-bucket"
    key    = "path/to/your/tofu.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }
  }
}

provider "aws" {
  region = local.region
}

# ---- Reusable constants

locals {
  name     = "dev"
  region   = "ap-northeast-1"
  azs      = ["ap-northeast-1a", "ap-northeast-1c"]
  vpc_cidr = "10.1.0.0/16"

  # See https://github.com/renovatebot/renovate/discussions/35132 for more details on this workaround
  # renovate:eks
  eks_version_raw = "1-34"
  eks_version     = replace(local.eks_version_raw, "-", ".")
}
