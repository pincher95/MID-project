output "aws_key_name" {
  value = aws_key_pair.server_key.*.id
}