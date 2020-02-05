output "aws_key_name" {
  value = aws_key_pair.server_key.*.id
}

output "project_private_key" {
  value = tls_private_key.server_key[0].private_key_pem
}