locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/ubuntu/jenkins_home"
  jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
  groovy_scripts_mount = "/tmp/init.groovy.d:/tmp/init.groovy.d"
  java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
  dockerhub_username = "pincher95"
  dockerhub_password = "123EVanmb"
  jenkins_username = "admin"
  jenkins_password = "admin"
  git_url = "https://github.com/pincher95/MID-project.git"
  project_name = "opsschool-mid-project"
  msg = "installing plugins"
}

//resource "local_file" "ssh" {
//  content     = <<-EOT
//    Host *
//      User ubuntu
//      IdentityFile ../keys/project.pem
//      ProxyCommand ssh -W %h:%p ubuntu@${var.bastion_ip[0]}
//    Host ${var.bastion_ip[0]}
//      Hostname ${var.bastion_ip[0]}
//      User ubuntu
//      IdentityFile ..keys/project.pem
//      ForwardAgent yes
//  EOT
//  filename = "../ansible/ssh.cfg"
//}

data "template_file" "jenkins_configure_dockerhub_credentials" {
  template = file("../templates/dockerhub_credentials.groovy.tpl")
  vars = {
    dockerhub_username = local.dockerhub_username
    dockerhub_password = local.dockerhub_password
  }
}

data "template_file" "install_plugins" {
  template = file("../templates/install_plugins.groovy.tpl")
  vars = {
    msg = local.msg
  }
}

data "template_file" "pipeline_init" {
  template = file("../templates/pipeline_init.groovy.tpl")
  vars = {
    git_url = local.git_url
    project_name = local.project_name
  }
}

data "template_file" "jenkins_configure_ssh" {
  template = file("../templates/ssh_credentials.groovy.tpl")
  vars = {
    jenkins_ssh_key = file(var.private_key_path)
  }
//  depends_on = [var.private_key]
}

data "template_file" "jenkins_configure_jenkins_credentials" {
  template = file("../templates/setup_users.groovy.tpl")
  vars = {
    jenkins_admin_user = local.jenkins_username
    jenkins_admin_password = local.jenkins_password
  }
}


//data "template_file" "jenkins_configure_ec2" {
//  template = file("${path.module}/templates/jenkins_confgure_ec2.groovy.tpl")
//  vars = {
//    jenkins_ec2_subnet = aws_subnet.public[0].id
//    jenkins_ec2_sg = aws_security_group.vpc-foaas-default.id
//    jenkins_ssh_key = file("${var.aws_key_path}")
//
//  }
//}


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

  provisioner "file" {
    source = var.private_key_path
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  provisioner "file" {
    source = var.public_key
    destination = "/home/ubuntu/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    content     = data.template_file.jenkins_configure_dockerhub_credentials.rendered
    destination = "/tmp/dockerhub_credentials.groovy"
  }

  provisioner "file" {
    content     = data.template_file.install_plugins.rendered
    destination = "/tmp/install_plugins.groovy"
  }

  provisioner "file" {
    content     = data.template_file.pipeline_init.rendered
    destination = "/tmp/pipeline_init.groovy"
  }
  provisioner "file" {
    content     = data.template_file.jenkins_configure_ssh.rendered
    destination = "/tmp/jenkins_configure_ssh.groovy"
  }

  provisioner "file" {
    content     = data.template_file.jenkins_configure_jenkins_credentials.rendered
    destination = "/tmp/setup_users.groovy"
  }

//  provisioner "file" {
//    content     = data.template_file.jenkins_configure_ec2.rendered
//    destination = "../templates/jenkins_configure.ec2.groovy"
//  }

//  provisioner "file" {
//    source      = "./init.groovy.d"
//    destination = "../tmp/init.groovy.d"
//  }
//
//  provisioner "remote-exec" {
//    script = "../scripts/restart_jenkins.sh"
//  }

  provisioner "remote-exec" {
    inline = [
//      "sudo apt-get update -y",
//      "sudo apt install docker.io -y",
//      "sudo systemctl start docker",
//      "sudo systemctl enable docker",
//      "sudo usermod -aG docker ubuntu",
      "mkdir -p ${local.jenkins_home}/init.groovy.d",
      "mv /tmp/*.groovy ${local.jenkins_home}/init.groovy.d/",
//      "mkdir -p ${local.jenkins_home}",
      "sudo chown -R ubuntu:ubuntu ${local.jenkins_home}",
      "sleep 30",
//      "sudo docker run -d -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }

  provisioner "local-exec" {
      working_dir = "../ansible"
      command = <<-EOT
        ssh-add ${var.private_key};
        export ANSIBLE_HOST_KEY_CHECKING=False;
        ansible-playbook -i ${aws_instance.jenkins_master.private_ip}, jenkins_master.yml --extra-vars "docker_users=ubuntu"
      EOT
    }
  tags = {
    Name = "Jenkins Master"
  }
}