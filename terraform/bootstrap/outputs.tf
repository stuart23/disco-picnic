output "state_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.tflock.name
}

output "aws_region" {
  value = var.aws_region
}

output "github_actions_role_arn" {
  description = "Put this in the repo's Actions → Variables as AWS_GITHUB_ACTIONS_ROLE_ARN."
  value       = aws_iam_role.github_actions.arn
}
