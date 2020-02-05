resource "aws_instance" "jenkins_agent" {
  ami = "ami-00068cd7555f543d5"
  instance_type = var.jenkis_ec2_type
  subnet_id = var.private_subnet[1]
  key_name = var.public_aws_key[0]
  vpc_security_group_ids = [var.jenkis_sg, var.private_sg, var.consul_client_sg]
  user_data = data.template_cloudinit_config.consul_client[1].rendered
  iam_instance_profile = aws_iam_instance_profile.eks-kubectl.name

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file(var.private_key)

    bastion_host = var.bastion_ip[0]
    bastion_user = "ubuntu"
  }

//  provisioner "file" {
//    source = "./kubeconfig"
//    destination = "/home/ec2-user"
//  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install java-1.8.0 docker git -y",
      "sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1",
      "sudo alternatives --config java <<< '1'",
      "curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin",
      "echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc",
      "curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator",
      "chmod +x ./aws-iam-authenticator",
      "mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin",
      "echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user"
    ]
  }

  tags = {
    Name = "Jenkins Agent"
  }
}
