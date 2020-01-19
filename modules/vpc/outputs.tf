output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "privare_subnet" {
  value = aws_subnet.private.*.id
}

output "public_subnet" {
  value = aws_subnet.public.*.id
}

output "private_sg" {
  value = aws_security_group.private-sg.id
}

output "public_sg" {
  value = aws_security_group.public-sg.id
}