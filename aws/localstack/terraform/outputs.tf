output "bucket_url" {
  value = aws_s3_bucket.local_bucket.bucket_regional_domain_name
}