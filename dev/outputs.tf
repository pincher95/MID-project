output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "jenkins_ip" {
  value = module.jenkins.jenkins_ip
}