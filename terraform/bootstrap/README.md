# bootstrap

Creates the foundational AWS resources the main `../` config depends on but
can't create for itself:

- an S3 bucket + DynamoDB table for Terraform remote state/locking
- a GitHub Actions OIDC role (no static AWS keys in GitHub) scoped to exactly
  one repo, with least-privilege access to the state bucket/lock table and
  the site's S3 bucket + CloudFront distribution

This module intentionally uses **local state** — it creates the very backend
everything else will use, so it can't use that backend itself. Keep
`bootstrap/terraform.tfstate` somewhere durable (it's small; a private repo,
or your password manager's secure notes, or an encrypted backup all work).
You'll re-run `terraform plan` here rarely, if ever, once it's applied.

## Run this first, once

```bash
cd bootstrap
export AWS_ACCESS_KEY_ID=...        # scoped IAM user, not root
export AWS_SECRET_ACCESS_KEY=...

terraform init
terraform apply -var="github_repository=YOUR_GH_ORG_OR_USER/YOUR_REPO_NAME"
```

If your AWS account already has a GitHub OIDC provider from some other
project (`token.actions.githubusercontent.com` — AWS only allows one per
account), add `-var="create_github_oidc_provider=false"`.

If `disco-picnic-tfstate` is already taken (S3 bucket names are global),
add `-var="state_bucket_name=something-else"`.

## After it applies

```bash
terraform output
```

1. Take `state_bucket` / `lock_table` / `aws_region` and put them into
   `../backend.tf` (already done for the defaults — only edit if you changed
   the variables above).
2. Take `github_actions_role_arn` and add it to the GitHub repo as an
   Actions **variable** named `AWS_GITHUB_ACTIONS_ROLE_ARN` (Settings →
   Secrets and variables → Actions → Variables). It's an ARN, not a secret,
   but a repo secret works fine too if you'd rather keep it there.
3. Add the two Porkbun values as Actions **secrets**: `PORKBUN_API_KEY`,
   `PORKBUN_SECRET_KEY`.
4. In `../`, run `terraform init -migrate-state` to move the existing local
   state (from the S3 bucket / CloudFront / DNS import you already did) into
   the new S3 backend.
