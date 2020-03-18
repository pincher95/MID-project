resource "aws_instance" "MYSQL_Slave" {
  ami           = "${var.ubuntu_image_16-04}"
  instance_type = "t2.micro"
  key_name        = "${var.aws_key_name}"
  subnet_id = "${aws_subnet.Subnet_main.id}"
  vpc_security_group_ids = ["${aws_security_group.SecurityGroup_main.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.Consul_IAM_Profile.name}"

  tags = {
    Name = "MySQL_Slave-TerraBuild"
  }

  user_data = "${file(var.mysql_Slave_user_data_script)}"
}