resource "aws_s3_bucket" "b" {
  bucket = "s3-bucket-frontend-todo-app-www.ekstodoapp.tk"
  acl    = "public-read"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicReadAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::s3-bucket-frontend-todo-app-www.ekstodoapp.tk/*"
        }
    ]
}
POLICY

  website {
    index_document = "index.html"
  }
  force_destroy = true
}

//resource "null_resource" "example1" {
//  provisioner "local-exec" {
//    command = "cd client && REACT_APP_HOST={var.go_server}  yarn build && aws s3 sync build/ s3://${aws_s3_bucket.b.bucket}" 
//  }
//}