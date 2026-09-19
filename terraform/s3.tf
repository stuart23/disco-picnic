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
