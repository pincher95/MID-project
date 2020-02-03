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

output "worker_sg" {
  value = aws_security_group.worker_group_mgmt_one.id
}

output "jenkins_sg" {
  value = aws_security_group.jenkins.id
}

output "consul_sg" {
  value = aws_security_group.opsschool_consul.id
}

output "consul_client_sg" {
  value = aws_security_group.opsschool_client.id
}
output "private_subnet_ern" {
  value = aws_subnet.private.*.arn
}