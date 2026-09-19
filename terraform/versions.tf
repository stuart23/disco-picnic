terraform {
  required_version = ">= 1.7.0" # needed for `terraform plan -generate-config-out`

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    porkbun = {
      source  = "jianyuan/porkbun"
      version = "~> 0.3"
    }
  }
}
