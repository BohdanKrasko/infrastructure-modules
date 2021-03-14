output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = data.aws_subnet_ids.public.ids
}

output "aws_lb_target_group_go_arn" {
  value = aws_lb_target_group.go.arn
}

output "aws_lb_go" {
  value = aws_lb.go
}




