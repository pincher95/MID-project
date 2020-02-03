output "jenkins_ip" {
  value = aws_instance.jenkins_master.private_ip
}

output "jenkins_agent_ip"{
  value = aws_instance.jenkins_agent.private_ip
}