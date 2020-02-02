# Create an IAM role for eks kubectl
resource "aws_iam_role" "eks-full" {
  description = "Accessing all of account EKS cluster API endpoints"
  name               = "opsschool-eks-full"
  assume_role_policy = file("./policy/assume-policy.json")
}

# Create the policy
resource "aws_iam_policy" "eks-full" {
  description = "EKS Full access policy"
  name        = "opsschool-eks-full"
  policy      = file("./policy/eks-full.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "eks-full" {
  name       = "opsschool-eks-full"
  roles      = [aws_iam_role.eks-full.name]
  policy_arn = aws_iam_policy.eks-full.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "eks-kubectl" {
  name  = "opsschool-eks-full"
  role = aws_iam_role.eks-full.name
}

data "template_file" "user_data_slave" {
  template = file("../scripts/join-cluster.sh.tpl")

  vars = {
    jenkins_url            = "http://${aws_instance.jenkins_master.private_ip}:8080"
    jenkins_username       = "admin"
    jenkins_password       = "admin"
    jenkins_credentials_id = file(var.public_key)
  }
}

resource "aws_instance" "jenkins_agent" {
  ami = "ami-00068cd7555f543d5"
  instance_type = var.jenkis_ec2_type
  subnet_id = var.private_subnet[1]
  key_name = var.public_aws_key[0]
  vpc_security_group_ids = [var.jenkis_sg, var.private_sg]
  user_data = data.template_file.user_data_slave.rendered
  iam_instance_profile = aws_iam_instance_profile.eks-kubectl.name
  depends_on = [aws_instance.jenkins_master]

  connection {
    host = self.private_ip
    user = "ec2-user"
    private_key = file(var.private_key_path)

    bastion_host = var.bastion_ip[0]
    bastion_user = "ubuntu"
  }

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
