variable "aws_region" {
  description = "Region for the state bucket, lock table, and IAM resources."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket to create for Terraform remote state. S3 bucket names are globally unique across ALL AWS accounts — if this name is taken, change it and re-apply."
  type        = string
  default     = "disco-picnic-tfstate"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  type        = string
  default     = "disco-picnic-tfstate-lock"
}

variable "github_repository" {
  description = "The GitHub repo allowed to assume the CI role, as \"org-or-user/repo-name\" (e.g. \"astronomer-stu/disco-picnic\"). REQUIRED — the IAM trust policy is scoped to exactly this repo."
  type        = string
  default     = "stuart23/disco-picnic"
}

variable "create_github_oidc_provider" {
  description = "Whether to create the GitHub Actions OIDC provider in this AWS account. AWS allows only ONE OIDC provider per URL per account — set this to false (and the module will look up the existing one) if some other stack in this account already created https://token.actions.githubusercontent.com."
  type        = bool
  default     = true
}

variable "site_bucket_name" {
  description = "The S3 bucket the CI role needs full access to (the site bucket managed by ../ )."
  type        = string
  default     = "disco-picnic.com"
}

variable "cloudfront_distribution_id" {
  description = "The CloudFront distribution the CI role needs to manage (the one imported in ../)."
  type        = string
  default     = "E1KWRAK6XGPAJU"
}
