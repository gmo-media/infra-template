# ---- Backend and providers

terraform {
  backend "s3" {
    bucket = "your-tfstate-bucket"
    key    = "path/to/your/tofu.tfstate"
  }
}

provider "aws" {
  region = local.region
}

# ---- Reusable constants

locals {
  region = "ap-northeast-1"
}
