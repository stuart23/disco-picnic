# Remote state, created by ./bootstrap. Values must be literals (Terraform
# backend blocks can't reference variables) — these match bootstrap's
# variable defaults. If you overrode state_bucket_name / lock_table_name /
# aws_region when applying bootstrap, update them here to match.
#
# First time adding this block to an existing local-state config, run:
#   terraform init -migrate-state

terraform {
  backend "s3" {
    bucket         = "disco-picnic-tfstate"
    key            = "site/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "disco-picnic-tfstate-lock"
    encrypt        = true
  }
}
