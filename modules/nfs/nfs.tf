resource "aws_instance" "nfs_server" {
  ami = "ami-07d0cf3af28718ef8"
  instance_type = var.ec2_type
  subnet_id = var.private_subnet[0]
  key_name = var.bootstrap_key[0]
  vpc_security_group_ids = [var.global_sg, var.consul_sg]
//  iam_instance_profile = var.instance_profile
//  user_data = data.template_cloudinit_config.consul_client[0].rendered

  connection {
    host = self.private_ip
    user = "ubuntu"
    private_key = file(var.private_key)

    bastion_host = var.bastion_ip[0]
    bastion_user = "ubuntu"
  }

//  provisioner "file" {
//    source      = file("../scripts/nfs-server.sh")
//    destination = "/tmp/nfs-server.sh"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "sudo chmod +x /tmp/nfs-server.sh",
//      "/tmp/nfs-server.sh",
//    ]
//  }
  tags = {
    Name = "NFS Server"
  }
}