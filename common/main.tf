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
  region = "ap-northeast-1"
}
