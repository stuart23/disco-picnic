# These import blocks bring the ALREADY-EXISTING bucket and distribution
# under Terraform management. IDs are hardcoded literals (not variables)
# because import block IDs must be known at plan time.
#
# Workflow (see README.md for full detail):
#   1. terraform init
#   2. terraform plan -generate-config-out=generated.tf
#      -> Terraform reads the real bucket + distribution and writes
#         resource blocks that match their current live configuration
#         into generated.tf. This avoids guessing at settings (cache
#         behaviors, OAC, aliases, cert ARN, etc.) that aren't visible
#         from here.
#   3. Review generated.tf, then move/rename its contents into
#      s3.tf / cloudfront.tf as you like.
#   4. terraform apply
#      -> Should show no changes for these two resources (they're
#         already exactly what's live); it will only create the new
#         Porkbun DNS records from dns.tf.
#   5. Once applied successfully, these import blocks can be deleted
#      (they're a no-op on resources already in state, but removing
#      them keeps the config clean).

import {
  to = aws_s3_bucket.site
  id = "disco-picnic.com"
}

import {
  to = aws_cloudfront_distribution.site
  id = "E1KWRAK6XGPAJU"
}
