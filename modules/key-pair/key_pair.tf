resource "tls_private_key" "server_key" {
  count = length(var.key_pair)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "server_key" {
  count = length(var.key_pair)
  key_name   = element(var.key_pair, count.index)
  public_key = tls_private_key.server_key[count.index].public_key_openssh
}

resource "local_file" "server_key_private" {
  count = length(var.key_pair)
  sensitive_content = tls_private_key.server_key[count.index].private_key_pem
  filename = "../${path.root}/keys/${element(var.key_pair, count.index)}.pem"
  file_permission = "0400"
}

resource "local_file" "server_key_public" {
  count = length(var.key_pair)
  sensitive_content = tls_private_key.server_key[count.index].public_key_pem
  filename = "../${path.root}/keys/${element(var.key_pair, count.index)}.pub"
  file_permission = "0400"
}

resource "local_file" "authorized_keys" {
  count = length(var.key_pair)
  sensitive_content = tls_private_key.server_key[count.index].public_key_openssh
  filename = "../${path.root}/keys/authorized_keys"
  file_permission = "0400"
}