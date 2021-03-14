resource "aws_security_group" "mongo_sg" {
  name        = "mongo_sg"
  description = "mongo"
  vpc_id      = var.vpc_id

  ingress {
    description = "mongo_sg"
    from_port   = 27017
    to_port     = 27017
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "go_sg" {
  name        = "go_sg"
  description = "go"
  vpc_id      = var.vpc_id

  ingress {
    description = "go"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}