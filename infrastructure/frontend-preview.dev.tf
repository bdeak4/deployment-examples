variable "frontend_preview_domain" {
  type     = string
  nullable = false
}

resource "aws_s3_bucket" "frontend_preview" {
  bucket        = "${var.project}-frontend-preview"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "frontend_preview" {
  bucket = aws_s3_bucket.frontend_preview.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "frontend_preview" {
  bucket = aws_s3_bucket.frontend_preview.id
  policy = data.aws_iam_policy_document.frontend_preview.json
}

data "aws_iam_policy_document" "frontend_preview" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_preview.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.frontend_preview.iam_arn]
    }
  }
}

resource "aws_cloudfront_distribution" "frontend_preview" {
  origin {
    domain_name = aws_s3_bucket.frontend_preview.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.frontend_preview.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_preview.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = aws_s3_bucket.frontend_preview.bucket
  price_class         = "PriceClass_200"
  aliases             = ["*.${var.frontend_preview_domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.frontend_preview.bucket
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.frontend_preview.qualified_arn
      include_body = true
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.frontend_preview.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend_preview" {
}

resource "aws_lambda_function" "frontend_preview" {
  function_name = "${var.project}-frontend-preview"
  role          = aws_iam_role.frontend_preview.arn
  runtime       = "nodejs14.x"
  handler       = "index.handler"

  filename         = "frontend_preview.zip"
  source_code_hash = filebase64sha256("frontend_preview.zip")
  publish          = true
  provider         = aws.force_us_east
}

data "aws_iam_policy_document" "frontend_preview_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "frontend_preview_logs" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_role" "frontend_preview" {
  name               = "${var.project}-frontend-preview"
  assume_role_policy = data.aws_iam_policy_document.frontend_preview_lambda.json
}

resource "aws_iam_policy" "frontend_preview" {
  name   = "${var.project}-frontend-preview"
  path   = "/"
  policy = data.aws_iam_policy_document.frontend_preview_logs.json
}

resource "aws_iam_role_policy_attachment" "frontend_preview" {
  role       = aws_iam_role.frontend_preview.name
  policy_arn = aws_iam_policy.frontend_preview.arn
}

resource "cloudflare_record" "frontend_preview" {
  zone_id         = var.zone_id
  name            = "*.${var.frontend_preview_domain}"
  value           = aws_cloudfront_distribution.frontend_preview.domain_name
  type            = "CNAME"
  proxied         = false
  allow_overwrite = true
}

resource "aws_acm_certificate" "frontend_preview" {
  domain_name       = "*.${var.frontend_preview_domain}"
  validation_method = "DNS"
  provider          = aws.force_us_east
}

resource "aws_acm_certificate_validation" "frontend_preview" {
  certificate_arn         = aws_acm_certificate.frontend_preview.arn
  validation_record_fqdns = [for record in cloudflare_record.frontend_preview_certificate_validation : record.hostname]
  provider                = aws.force_us_east
}

resource "cloudflare_record" "frontend_preview_certificate_validation" {
  for_each = {
    for v in aws_acm_certificate.frontend_preview.domain_validation_options : v.domain_name => {
      name   = v.resource_record_name
      record = v.resource_record_value
      type   = v.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  value           = each.value.record
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}
