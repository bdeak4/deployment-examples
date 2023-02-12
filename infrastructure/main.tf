terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }

  backend "s3" {}

  required_version = ">= 1.2.0"
}

provider "aws" {
  # creds from $AWS_ACCESS_KEY_ID and $AWS_SECRET_ACCESS_KEY
  region = var.region
}

provider "aws" {
  alias  = "force_us_east"
  region = "us-east-1"
}

provider "cloudflare" {
  # creds from $CLOUDFLARE_API_TOKEN
}

variable "project" {
  type     = string
  nullable = false
}

variable "env" {
  type     = string
  nullable = false
}

variable "region" {
  type     = string
  nullable = false
}

variable "zone_id" {
  type     = string
  nullable = false
}
