locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}

resource "aws_instance" "jenkins_master" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = var.jenkis_ec2_type
  subnet_id = var.private_subnet[0]
  #TODO create key pair for jenkins cluster
  key_name = aws_key_pair.server_key[0].key_name
  vpc_security_group_ids = [var.jenkis_sg, var.private_sg]
  depends_on = [local_file.server_key_private]

  connection {
    host = self.private_ip
    user = "ubuntu"
    private_key = file(var.private_key_path)

    bastion_host = aws_instance.bastion-server[0].public_ip
    bastion_user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      #TODO create parametars
      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R 1000:1000 ${local.jenkins_home}"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      #TODO need to deside how to provision and fire up jenkins master
      "sudo docker run -d -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }

  tags = {
    Name = "Jenkins Master"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami = "ami-00068cd7555f543d5"
  instance_type = var.jenkis_ec2_type
  subnet_id = var.private_subnet[1]
  key_name = aws_key_pair.server_key[0].key_name
  vpc_security_group_ids = [var.jenkis_sg, var.private_sg]
  depends_on = [local_file.server_key_private]

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file(var.private_key_path)

    bastion_host = aws_instance.bastion-server[0].public_ip
    bastion_user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install java-1.8.0 docker git -y",
      "sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1",
      "sudo alternatives --config java",
//      "sudo yum install docker git -y",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user"
    ]
  }


  tags = {
    Name = "Jenkins Agent"
  }
}