output "web-instance" {
  value = aws_instance.web-server.*.id
}