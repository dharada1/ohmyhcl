terraform {
  required_providers {
    aws = {
      version = "3.74.0"
    }
  }
}

provider "aws" {}

provider "random" {}

variable "bucket_name" {
  default = "tf-acc-test-abc12345"
  type    = string
}

data "aws_canonical_user_id" "current" {}

data "aws_partition" "current" {}

resource "random_pet" "example" {}

resource "aws_s3_bucket" "b" {
  bucket = random_pet.example.id

}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "my-example-log-bucket-44444"

}

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name












}
resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.b.id
  acl    = "public-read"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "b_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.b.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.arbitrary.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_accelerate_configuration" "example_acceleration_configuration" {
  bucket = aws_s3_bucket.example.id
  status = "Enabled"
}

resource "aws_s3_bucket_policy" "example_policy" {
  bucket = aws_s3_bucket.example.id
  policy = <<POLICY
  {
    "Version":"2008-10-17",
    "Statement": [
      {
        "Sid":"AllowPublicRead",
        "Effect":"Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}/*"
      }
    ]
  }
  POLICY
}

resource "aws_s3_bucket_request_payment_configuration" "example_request_payment_configuration" {
  bucket = aws_s3_bucket.example.id
  payer  = "Requester"
}

resource "aws_s3_bucket_cors_configuration" "example_cors_configuration" {
  bucket = aws_s3_bucket.example.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://www.example.com"]
    expose_headers  = ["x-amz-server-side-encryption", "ETag"]
    max_age_seconds = 3000
  }
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = [""]
    expose_headers  = ["x-amz-server-side-encryption", "ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "example_acl" {
  bucket = aws_s3_bucket.example.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "WRITE"
    }
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
        type = "Group"
      }
      permission = "READ_ACP"
    }
  }
}

resource "aws_s3_bucket_logging" "example_logging" {
  bucket        = aws_s3_bucket.example.id
  target_prefix = "log/"
  target_bucket = aws_s3_bucket.log_bucket.id
}

resource "aws_s3_bucket_versioning" "example_versioning" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "example_object_lock_configuration" {
  bucket              = aws_s3_bucket.example.id
  object_lock_enabled = "Enabled"
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 3
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "example_replication_configuration" {
  bucket = aws_s3_bucket.example.id
  role   = aws_iam_role.role.arn
  rule {
    id       = "rule1"
    priority = 1
    status   = "Enabled"
    delete_marker_replication {
      status = "Enabled"
    }
    filter {
      prefix = "prefix1"
    }
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
  rule {
    priority = 2
    status   = "Enabled"
    id       = "rule2"
    filter {
      and {
        tags = {
          Key2 = "Value2"
        }
        prefix = ""
      }
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.example.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.arbitrary.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_website_configuration" "example_website_configuration" {
  bucket = aws_s3_bucket.example.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}
