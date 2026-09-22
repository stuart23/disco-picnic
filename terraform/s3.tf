# Generated from the real bucket via `terraform plan -generate-config-out`
# (see import.tf), then moved here.

resource "aws_s3_bucket" "site" {
  bucket              = var.bucket_name
  bucket_prefix       = null
  force_destroy       = null
  object_lock_enabled = false
  tags                = {}
  tags_all            = {}
}

# NOTE: CloudFront's origin for this bucket is the S3 *website* endpoint
# (disco-picnic.com.s3-website-us-west-1.amazonaws.com), meaning static
# website hosting is enabled on this bucket — but generate-config-out did
# not produce an `aws_s3_bucket_website_configuration` resource for it
# (config generation doesn't cover every sub-resource type). That website
# config exists and is live, it's just not Terraform-managed yet. If you
# want it under management too, run:
#   aws s3api get-bucket-website --bucket disco-picnic.com
# and I can turn that into a resource block here.

# Assets are apparently also being fetched directly from the S3 REST
# endpoint (not just through CloudFront's website-endpoint origin), which
# had no CORS rules at all. This allows GET/HEAD from the site's own
# domains and the CloudFront distribution's own hostname.
resource "aws_s3_bucket_cors_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = [
      "https://${var.domain_name}",
      "https://www.${var.domain_name}",
      "https://${aws_cloudfront_distribution.site.domain_name}",
    ]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}
