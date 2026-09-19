variable "aws_region" {
  description = "AWS region the S3 bucket actually lives in (confirmed via the CloudFront origin: disco-picnic.com.s3-website-us-west-1.amazonaws.com). CloudFront itself is a global service and isn't affected by this setting."
  type        = string
  default     = "us-west-1"
}

variable "bucket_name" {
  description = "Name of the existing S3 bucket that serves the site."
  type        = string
  default     = "disco-picnic.com"
}

variable "cloudfront_distribution_id" {
  description = "ID of the existing CloudFront distribution in front of the bucket."
  type        = string
  default     = "E1KWRAK6XGPAJU"
}

variable "domain_name" {
  description = "Apex domain managed in Porkbun."
  type        = string
  default     = "disco-picnic.com"
}
