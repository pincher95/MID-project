output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip[0]
}

output "helm_out" {
  value = module.helm.helm_status
}
//output "jenkins_ip" {
//  value = module.jenkins.jenkins_ip
//}
//
//output "jenkin_agent_ip" {
//  value = module.jenkins.jenkins_agent_ip
//}

