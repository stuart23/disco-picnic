# Lets GitHub Actions in var.github_repository assume an AWS role via OIDC —
# no long-lived AWS access keys stored in GitHub secrets.

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # GitHub's OIDC intermediate CA thumbprints. AWS also validates the cert
  # chain itself, so this list only needs to stay non-empty; it does not
  # need to be kept in perfect sync with GitHub's actual CA.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

# If some other stack in this AWS account already created the GitHub OIDC
# provider (only one is allowed per URL per account), set
# create_github_oidc_provider = false and this data source finds it instead.
data "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

locals {
  github_oidc_provider_arn = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-disco-picnic-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = local.github_oidc_provider_arn }
        # aws-actions/configure-aws-credentials tags the assumed session with
        # repo/branch/commit/actor info by default (useful in CloudTrail) —
        # that requires sts:TagSession in the same call, or AWS rejects the
        # whole AssumeRoleWithWebIdentity request.
        Action = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Any branch/tag/PR in this one repo may assume the role; the
            # workflow itself (triggers: push to main, workflow_dispatch)
            # is what actually restricts when apply runs.
            "token.actions.githubusercontent.com:sub": [
              "repo:${var.github_repository}",
              "repo:${var.github_repository}:*"
            ]
          }
        }
      }
    ]
  })
}

# Least-privilege for exactly what `terraform apply` in ../ needs to touch:
# the state bucket, the lock table, the site bucket, and the one CloudFront
# distribution. Nothing else in the account.
resource "aws_iam_role_policy" "github_actions" {
  name = "terraform-apply"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TerraformState"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [aws_s3_bucket.tfstate.arn, "${aws_s3_bucket.tfstate.arn}/*"]
      },
      {
        Sid      = "TerraformLock"
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        Resource = aws_dynamodb_table.tflock.arn
      },
      {
        Sid      = "SiteBucket"
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = [
          "arn:aws:s3:::${var.site_bucket_name}",
          "arn:aws:s3:::${var.site_bucket_name}/*",
        ]
      },
      {
        Sid    = "SiteDistribution"
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution",
          "cloudfront:ListTagsForResource",
          "cloudfront:TagResource",
          "cloudfront:UntagResource",
        ]
        Resource = "arn:aws:cloudfront::*:distribution/${var.cloudfront_distribution_id}"
      },
    ]
  })
}
