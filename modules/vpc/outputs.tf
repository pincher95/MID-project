output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "privare_subnet" {
  value = aws_subnet.db-private.*.id
}

output "public_subnet" {
  value = aws_subnet.web-public.*.id
}

output "private_sg" {
  value = aws_security_group.db-sg.id
}

output "public_sg" {
  value = aws_security_group.web-sg.id
}