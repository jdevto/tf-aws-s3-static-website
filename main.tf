provider "aws" {
  region = "ap-southeast-2"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "s3_static_website" {
  source = "tfstack/s3-static-website/aws"

  s3_config = {
    bucket_name          = "s3-static-site"
    bucket_acl           = "public-read"
    bucket_suffix        = random_string.suffix.result
    enable_force_destroy = true
    object_ownership     = "BucketOwnerPreferred"
    enable_versioning    = true
    index_document       = "index.html"
    error_document       = "error.html"
    public_access = {
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
    }
    source_file_path = "${path.module}/external"
  }

  cdn_config = {
    enable = true
    domain = {
      name     = "example.com"
      sub_name = "web"
    }
  }

  logging_config = {
    enable = true
  }

  tags = {
    Name = "s3-static-site-${random_string.suffix.result}"
  }
}

output "cloudfront_website_url" {
  value = module.s3_static_website.cloudfront_website_url
}

output "website_url" {
  value = module.s3_static_website.website_url
}

output "s3_website_url" {
  value = module.s3_static_website.s3_website_url
}
