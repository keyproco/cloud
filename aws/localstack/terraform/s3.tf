resource "aws_s3_bucket" "local_bucket" {
  bucket = "local-bucket"
}

resource "aws_s3_object" "hello_file" {
  bucket = aws_s3_bucket.local_bucket.bucket
  key    = "hello.txt"
  source = "./files/hello.txt"
}