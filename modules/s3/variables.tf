variable "s3_bucket_name" {
  type        = string
  description = "s3-bucket-frontend-todo-app-www.ekstodoapp.tk"
}

variable "go_server" {
  type    = string
  default = "https://prod.go.ekstodoapp.tk"
}