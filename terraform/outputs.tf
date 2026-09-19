output "cloudfront_domain_name" {
  description = "The *.cloudfront.net domain for the distribution — this is what DNS records point at."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.site.id
}

output "bucket_name" {
  value = aws_s3_bucket.site.bucket
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.site.bucket_regional_domain_name
}
