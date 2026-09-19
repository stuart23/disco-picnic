variable "aws_region" {
  description = "AWS region for the S3 bucket. CloudFront itself is global, but ACM certs used by CloudFront must live in us-east-1."
  type        = string
  default     = "us-east-1"
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
