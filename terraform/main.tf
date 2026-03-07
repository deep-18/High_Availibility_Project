# resource "aws_instance" "host" {
#     ami = "ami-0b6c6ebed2801a5cb"
#     instance_type = "t3.micro"
#     tags = {
#       project = "deployment"
#     }
# }

resource "aws_s3_bucket" "bucket_main" {
  bucket = "options-trading-bucket-main"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "bucket_secondary" {
  bucket = "options-trading-bucket-secondary"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "example_main" {
  bucket = aws_s3_bucket.bucket_main.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_public_access_block" "example_secondary" {
  bucket = aws_s3_bucket.bucket_secondary.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "versioning_configuration_main" {
  bucket = aws_s3_bucket.bucket_main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "versioning_configuration_secondary" {
  bucket = aws_s3_bucket.bucket_secondary.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "tf-iam-role-replication-12345"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.bucket_main.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.bucket_main.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.bucket_secondary.arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "tf-iam-role-policy-replication-12345"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}


resource "aws_s3_bucket_replication_configuration" "east_to_west" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning_configuration_main, aws_s3_bucket_versioning.versioning_configuration_secondary]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.bucket_main.id

  rule {
    id = "foobar"
    status = "Enabled"
    filter {}
    destination {
      bucket        = aws_s3_bucket.bucket_secondary.arn
      storage_class = "STANDARD"
    }
  }
}