resource "aws_s3_bucket" "b" {
  bucket = var.s3_bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
  force_destroy = true
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicReadAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.b.bucket}/*"
        }
    ]
}
POLICY
}
//resource "null_resource" "example1" {
//  provisioner "local-exec" {
//    command = "cd client && REACT_APP_HOST={var.go_server}  yarn build && aws s3 sync build/ s3://${aws_s3_bucket.b.bucket}" 
//  }
//}