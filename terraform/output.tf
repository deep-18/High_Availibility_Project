output "s3_bucket" {
    value = aws_s3_bucket.bucket_main.arn
}
output "private_instance_ip" {
    value = aws_s3_bucket.bucket_secondary.arn
}