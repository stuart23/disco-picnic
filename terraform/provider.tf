# --- Credentials are NEVER set in this file. ---
#
# AWS: use a scoped IAM user/role, not the account root user's access keys.
#   export AWS_ACCESS_KEY_ID=...
#   export AWS_SECRET_ACCESS_KEY=...
#   (or AWS_PROFILE=<a profile in ~/.aws/credentials>)
#
# Porkbun: create an API key/secret at https://porkbun.com/account/api
#   export PORKBUN_API_KEY=pk1_...
#   export PORKBUN_SECRET_KEY=sk1_...
#
# The providers below read those env vars automatically.

provider "aws" {
  region = var.aws_region
}

provider "porkbun" {
  # api_key and secret_key are sourced from PORKBUN_API_KEY / PORKBUN_SECRET_KEY
}
