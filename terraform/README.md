# disco-picnic.com infrastructure

Manages, via Terraform:
- the existing S3 bucket serving the site (`disco-picnic.com`)
- the existing CloudFront distribution in front of it (`E1KWRAK6XGPAJU`)
- Porkbun DNS records (apex + `www`) pointing at that distribution

using the [`hashicorp/aws`](https://registry.terraform.io/providers/hashicorp/aws/latest) and
[`jianyuan/porkbun`](https://registry.terraform.io/providers/jianyuan/porkbun/latest) providers.

## 1. Credentials (never stored in this repo)

**AWS** — use a scoped IAM user or role, *not* the account's root access keys.
Root keys have unrestricted account access; a minimal policy for this config needs
roughly `s3:*` on the one bucket and `cloudfront:*` on the one distribution.

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
# or: export AWS_PROFILE=some-profile-in-~/.aws/credentials
```

**Porkbun** — generate an API key/secret at https://porkbun.com/account/api
(you must also toggle "API Access" on for the domain in its domain settings).

```bash
export PORKBUN_API_KEY=pk1_...
export PORKBUN_SECRET_KEY=sk1_...
```

## 2. Bring the existing AWS resources under management

This uses Terraform's `import` blocks (`import.tf`) together with
`-generate-config-out`, which reads the *real, live* bucket and distribution
and writes matching resource config for you — this avoids hand-guessing
things like cache behaviors, the origin access control, aliases, or the ACM
certificate ARN, none of which are knowable without querying AWS directly.

```bash
terraform init
terraform plan -generate-config-out=generated.tf
```

Open `generated.tf`, sanity-check it, then move the `aws_s3_bucket.site` block
(and any related `aws_s3_bucket_*` sub-resources Terraform generated —
versioning, public access block, bucket policy, website config, etc.) into
`s3.tf`, and the `aws_cloudfront_distribution.site` block into `cloudfront.tf`.
Delete `generated.tf` once you've moved its contents.

```bash
terraform apply
```

This should show **no changes** for the bucket/distribution (they're already
exactly what's live) and will create the two new `porkbun_dns_record`
resources.

Once applied cleanly, you can delete `import.tf` — the import already happened
and is now reflected in `terraform.tfstate`.

## 3. DNS

If `disco-picnic.com` or `www.disco-picnic.com` already have A/ALIAS/CNAME
records in Porkbun from before (likely, since the site is already live),
`terraform apply` will fail on a duplicate record. Two options:

- **Delete the old records** in the Porkbun dashboard, then `terraform apply`
  to have Terraform create fresh ones, or
- **Import the existing records** instead:

  ```bash
  # find the record ID (Porkbun dashboard, or the API):
  curl -s https://api.porkbun.com/api/json/v3/dns/retrieve/disco-picnic.com \
    -d '{"apikey":"'"$PORKBUN_API_KEY"'","secretapikey":"'"$PORKBUN_SECRET_KEY"'"}'

  terraform import porkbun_dns_record.apex <record_id>_disco-picnic.com_ALIAS
  terraform import porkbun_dns_record.www   <record_id>_disco-picnic.com_CNAME
  ```

  Then `terraform plan` to confirm the imported records match `dns.tf`
  (adjust TTL/content in `dns.tf` if they differ).

## 4. Remote state + CI

State lives in S3 (`backend.tf`), backed by a bucket + DynamoDB lock table
created by the **`bootstrap/`** module — see `bootstrap/README.md`. Run that
once, first, then:

```bash
terraform init -migrate-state   # moves local state into the new S3 backend
```

`bootstrap/` also creates the IAM role that GitHub Actions assumes (via OIDC,
no stored AWS keys) to run `terraform apply` automatically. See
`.github/workflows/terraform-apply.yml` — it runs on every push to `main`
and via manual dispatch. It needs these set in the GitHub repo (values come
from `terraform output` in `bootstrap/`):

- Actions variable `AWS_GITHUB_ACTIONS_ROLE_ARN`
- Actions secrets `PORKBUN_API_KEY`, `PORKBUN_SECRET_KEY`

If you'd rather not use CI yet, everything above still works purely from
your own machine with local env-var credentials.

## Files

| File | Purpose |
|---|---|
| `versions.tf` | Provider version pins |
| `provider.tf` | Provider blocks (reads creds from env vars) |
| `variables.tf` | Bucket name, distribution ID, domain name, region |
| `backend.tf` | S3 remote state config (points at `bootstrap/`'s bucket/table) |
| `import.tf` | One-time import blocks for the existing bucket + distribution |
| `s3.tf` | Generated: the S3 bucket resource(s) |
| `cloudfront.tf` | Generated: the CloudFront distribution resource |
| `dns.tf` | Porkbun DNS records (apex ALIAS + www CNAME) |
| `outputs.tf` | Useful values after apply |
| `bootstrap/` | Separate module: state bucket, lock table, GitHub OIDC role (apply this first) |
