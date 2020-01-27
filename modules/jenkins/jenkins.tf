locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}

resource "local_file" "ssh" {
  content     = <<-EOT
    Host *
      User ubuntu
      IdentityFile ../keys/project.pem
      ProxyCommand ssh -W %h:%p ubuntu@${var.bastion_ip[0]}

    Host ${var.bastion_ip[0]}
      Hostname ${var.bastion_ip[0]}
      User ubuntu
      IdentityFile ..keys/project.pem
      ForwardAgent yes
  EOT
  filename = "../ansible/ssh.cfg"
}

resource "aws_instance" "jenkins_master" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = var.jenkis_ec2_type
  subnet_id = var.private_subnet[0]
  key_name = var.public_aws_key[0]
  vpc_security_group_ids = [var.jenkis_sg, var.private_sg]

  connection {
    host = self.private_ip
    user = "ubuntu"
    private_key = file(var.private_key_path)

    bastion_host = var.bastion_ip[0]
    bastion_user = "ubuntu"
  }

//  provisioner "remote-exec" {
//    inline = [
//      "sudo apt-get update -y",
//      "sudo apt install docker.io -y",
//      "sudo systemctl start docker",
//      "sudo systemctl enable docker",
//      "sudo usermod -aG docker ubuntu",
//      "mkdir -p ${local.jenkins_home}",
//      "sudo chown -R 1000:1000 ${local.jenkins_home}",
//      "sleep 30",
//      "sudo docker run -d -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
//    ]
//  }

    provisioner "local-exec" {
      working_dir = "../ansible"
      command = <<-EOT
        sleep 30;
        ssh-add ${var.private_key};
        ansible-playbook -i ${aws_instance.jenkins_master.private_ip}, docker.yml
      EOT
    }
  tags = {
    Name = "Jenkins Master"
  }
}

//resource "aws_instance" "jenkins_agent" {
//  ami = "ami-00068cd7555f543d5"
//  instance_type = var.jenkis_ec2_type
//  subnet_id = var.private_subnet[1]
//  key_name = var.public_aws_key[0]
//  vpc_security_group_ids = [var.jenkis_sg, var.private_sg]
//
//  connection {
//    host = self.private_ip
//    user = "ec2-user"
//    private_key = file(var.private_key_path)
//
//    bastion_host = var.bastion_ip[0]
//    bastion_user = "ubuntu"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "sudo yum update -y",
//      "sudo yum install java-1.8.0 docker git -y",
//      "sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1",
//      "sudo alternatives --config java <<< '1'",
//      "sudo service docker start",
//      "sudo usermod -aG docker ec2-user"
//    ]
//  }
//
//
//  tags = {
//    Name = "Jenkins Agent"
//  }
//}