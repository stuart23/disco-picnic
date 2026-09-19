# Same rule as the main config: no credentials in files.
#   export AWS_ACCESS_KEY_ID=...      (scoped IAM user, not root)
#   export AWS_SECRET_ACCESS_KEY=...
# or export AWS_PROFILE=...

provider "aws" {
  region = var.aws_region
}
