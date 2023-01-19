terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }

  backend "s3" {}

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
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
