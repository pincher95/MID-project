data "template_file" "client" {
  template = file("../templates/consul.sh.tpl")
  count = 2
  vars = {
    CONSUL_VERSION = "1.6.2"
    CONFIG = <<-EOT
      "node_name": "${var.namespace}-client-${count.index}",
      "retry_join": ["provider=aws tag_key=${var.consul_join_tag_key} tag_value=${var.consul_join_tag_value}"],
      "server": false,
      "enable_script_checks": true
    EOT
  }
}

data "template_cloudinit_config" "consul_client" {
  count    = 2
  part {
    content = element(data.template_file.client.*.rendered, count.index)

  }
  part {
    content = file("../templates/webserver.sh.tpl")
  }
}

data "template_file" "create_permanent_agent" {
  template = file("../templates/create_permanent_agent.groovy.tpl")
  vars = {
    jenkins_agent_ip = aws_instance.jenkins_agent.private_ip
  }
}

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
    jenkins_slave_name = "ec2-user"
  }
  depends_on = [var.module_depends_on]
}

data "template_file" "jenkins_configure_jenkins_credentials" {
  template = file("../templates/setup_users.groovy.tpl")
  vars = {
    jenkins_admin_user = local.jenkins_username
    jenkins_admin_password = local.jenkins_password
  }
}

