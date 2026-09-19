terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Deliberately local state: this module creates the S3 bucket + DynamoDB
  # table that the *other* config uses as its remote backend, so it can't
  # use that backend itself (chicken-and-egg). Keep bootstrap/terraform.tfstate
  # safe (back it up somewhere durable) since it's the only record of these
  # foundational resources.
}
