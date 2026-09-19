# Generated from the real distribution via `terraform plan -generate-config-out`
# (see import.tf), then moved here.
#
# IMPORTANT: the live distribution came back with `aliases = []` — it
# currently accepts requests only via its own *.cloudfront.net hostname,
# not via disco-picnic.com/www.disco-picnic.com. Since dns.tf is about to
# point those domains at it, I added them to `aliases` below so CloudFront
# will actually accept and serve those hostnames — without this, once DNS
# resolves, CloudFront would reject the requests (400/403). This is a REAL
# change to the live distribution, not just import bookkeeping — `terraform
# plan` will show it as an update. The distribution already has a specific
# ACM certificate (not the CloudFront default), which strongly suggests
# these aliases were the intent; double check that cert actually covers
# disco-picnic.com and www.disco-picnic.com before applying.

resource "aws_cloudfront_distribution" "site" {
  aliases                         = [var.domain_name, "www.${var.domain_name}"]
  comment                         = null
  continuous_deployment_policy_id = null
  default_root_object             = "index.html"
  enabled                         = true
  http_version                    = "http2"
  is_ipv6_enabled                 = false
  price_class                     = "PriceClass_100"
  retain_on_delete                = false
  staging                         = false
  tags = {
    Name = "disco-picnic"
  }
  tags_all = {
    Name = "disco-picnic"
  }
  wait_for_deployment = true
  web_acl_id          = null

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    field_level_encryption_id  = null
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = null
    realtime_log_config_arn    = null
    response_headers_policy_id = null
    smooth_streaming           = false
    target_origin_id           = "disco-picnic.com.s3.us-west-1.amazonaws.com"
    trusted_key_groups         = []
    trusted_signers            = []
    viewer_protocol_policy     = "redirect-to-https"

    grpc_config {
      enabled = false
    }
  }

  logging_config {
    bucket          = "disco-picnic-logs.s3.amazonaws.com"
    include_cookies = false
    prefix          = null
  }

  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = "disco-picnic.com.s3-website-us-west-1.amazonaws.com"
    origin_access_control_id = null
    origin_id                = "disco-picnic.com.s3.us-west-1.amazonaws.com"
    origin_path              = null

    custom_origin_config {
      http_port                = 80
      https_port                = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:015140017687:certificate/69d651d6-9855-44b7-a1b9-e0ee268c0fa3"
    cloudfront_default_certificate = false
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}
