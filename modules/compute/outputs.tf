//output "web-instance" {
//  value = aws_instance.web-server.*.id
//}
output "key" {
  value = var.key_pair
}

output "local_private" {
  value = local_file.server_key_private[0].filename
}

output "public_ip" {
  value = aws_instance.bastion-server[0].public_ip
}
