# Points disco-picnic.com and www.disco-picnic.com at the CloudFront distribution.
#
# IMPORTANT: if these records (or any A/CNAME/ALIAS records on the apex or
# "www") already exist in Porkbun from before this config existed, applying
# this as-is will fail with a duplicate-record error. Either:
#   a) delete the conflicting records in the Porkbun dashboard first, or
#   b) import them instead of letting Terraform create them:
#        terraform import porkbun_dns_record.apex <record_id>_disco-picnic.com_ALIAS
#        terraform import porkbun_dns_record.www   <record_id>_disco-picnic.com_CNAME
#      (find <record_id> via the Porkbun dashboard or the "DNS Retrieve
#      Records" API call — see README.md)

resource "porkbun_dns_record" "apex" {
  domain = var.domain_name

  type    = "ALIAS" # Porkbun's flattened-CNAME equivalent for apex/root records
  content = aws_cloudfront_distribution.site.domain_name
}

resource "porkbun_dns_record" "www" {
  domain = var.domain_name

  subdomain = "www"
  type      = "CNAME"
  content   = aws_cloudfront_distribution.site.domain_name
}
