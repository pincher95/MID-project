output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip[0]
}