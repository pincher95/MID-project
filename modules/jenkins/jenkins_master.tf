locals {
  jenkins_default_name = "jenkins"
  jenkins_home = "/home/jenkins/jenkins_home"
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

resource "aws_instance" "jenkins_master" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = var.jenkis_ec2_type
  subnet_id = var.private_subnet[0]
  key_name = var.bootstrap_key[0]
  vpc_security_group_ids = [var.jenkis_sg, var.global_sg, var.consul_sg]
  iam_instance_profile = var.instance_profile
  user_data = data.template_cloudinit_config.consul_client[0].rendered

  connection {
    host = self.private_ip
    user = "ubuntu"
    private_key = file(var.private_key)

    bastion_host = var.bastion_ip[0]
    bastion_user = "ubuntu"
  }

  provisioner "file" {
    source = var.private_key
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

//  provisioner "file" {
//    content     = data.template_file.install_plugins.rendered
//    destination = "/tmp/install_plugins.groovy"
//  }

  provisioner "file" {
    content     = data.template_file.pipeline_init.rendered
    destination = "/tmp/pipeline_init.groovy"
  }

//  provisioner "file" {
//    content     = data.template_file.create_permanent_agent.rendered
//    destination = "/tmp/create_permanent_agent.groovy"
//  }

  provisioner "file" {
    content     = data.template_file.jenkins_configure_ssh.rendered
    destination = "/tmp/jenkins_configure_ssh.groovy"
  }

  provisioner "file" {
    content     = data.template_file.jenkins_configure_jenkins_credentials.rendered
    destination = "/tmp/setup_users.groovy"
  }

//  provisioner "local-exec" {
//    working_dir = "../ansible"
//    command = <<-EOT
//        ssh-add ${var.private_key};
//        export ANSIBLE_HOST_KEY_CHECKING=False;
//        sleep 10;
//        ansible-playbook -i ${aws_instance.jenkins_master.private_ip}, jenkins_master.yml --extra-vars "docker_users=ubuntu"
//      EOT
//  }

  provisioner "remote-exec" {
    inline = [
//      "sudo apt-get update -y",
//      "sudo apt install docker.io -y",
//      "sudo systemctl start docker",
//      "sudo systemctl enable docker",
//      "sudo usermod -aG docker ubuntu",
      "sudo apt install nfs-kernel-server -y",
      "sudo systemctl enable --now nfs-server",
      "sudo useradd -m -s /bin/nologin jenkins",
      "sudo mkdir -p ${local.jenkins_home}/init.groovy.d",
      "sudo mv /tmp/*.groovy ${local.jenkins_home}/init.groovy.d/",
      "sudo chown -R jenkins:jenkins ${local.jenkins_home}",
      "echo '${local.jenkins_home} *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports",
      "sudo exportfs -ar"
//      "sleep 60",
//      "sudo docker run -d -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins"
    ]
  }

  tags = {
    Name = "Jenkins Master"
  }
}