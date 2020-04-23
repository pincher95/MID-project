//resource "null_resource" "delay" {
//  provisioner "local-exec" {
//    command = "sleep 10"
//  }
//  triggers = {
//    delay = var.delay
//  }
//}

data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com"
}

data "helm_repository" "elastic" {
  name = "elastic"
  url = "https://helm.elastic.co"
}

data "helm_repository" "bitnami" {
  name = "bitnami"
  url = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "consul-helm" {
  chart = "consul-helm"
  repository = "./charts/"
  name = "consul"
  version = "0.18.0"
  namespace = "kube-consul"
  values = [
    file("./charts/values-store/consul-values.yaml")
  ]
//  depends_on = [null_resource.delay]
}

resource "null_resource" "coreDNS-custom" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl replace --kubeconfig ../kubeconfig -n kube-system -f coredns-custom.yaml
      kubectl apply --kubeconfig ../kubeconfig -f servicemonitors.coreos.com.yaml
    EOT
  }
  depends_on = [helm_release.consul-helm]
}

resource "helm_release" "prometheus" {
  chart = "prometheus"
  repository = data.helm_repository.stable.metadata[0].name
  name = "prometheus"
  version = "11.0.4"
  namespace = "kube-metrics"
  values = [
    file("./charts/values-store/prometheus-values.yaml")
  ]
  depends_on = [null_resource.coreDNS-custom]
}

resource "helm_release" "grafana" {
  chart = "grafana"
  repository = data.helm_repository.stable.metadata[0].name
  name = "grafana"
  version = "5.0.11"
  namespace = "kube-metrics"
  values = [
    file("./charts/values-store/grafana-values.yaml")
  ]
  depends_on = [helm_release.prometheus]
}

resource "helm_release" "elasticsearch" {
  chart = "elasticsearch"
  repository = data.helm_repository.bitnami.metadata[0].name
  name = "elasticsearch"
  version = "11.0.17"
  namespace = "kube-logging"
  values = [
    file("./charts/values-store/elasticsearch-values.yaml")
  ]
  depends_on = [helm_release.grafana]
}

resource "helm_release" "kibana" {
  chart = "kibana"
  repository = data.helm_repository.bitnami.metadata[0].name
  name = "kibana"
  version = "5.0.13"
  namespace = "kube-logging"
  values = [
    file("./charts/values-store/kibana-values.yaml")
  ]
  depends_on = [helm_release.elasticsearch]
}

resource "helm_release" "logstash" {
  chart = "logstash"
  repository = data.helm_repository.stable.metadata[0].name
  name = "logstash"
  version = "2.4.0"
  namespace = "kube-logging"
  values = [
    file("./charts/values-store/logstash-values.yaml")
  ]
  depends_on = [helm_release.kibana]
}

resource "helm_release" "filebeat" {
  chart = "filebeat"
  repository = data.helm_repository.stable.metadata[0].name
  name = "filebeat"
  version = "4.0.0"
  namespace = "kube-logging"
  values = [
    file("./charts/values-store/filebeat-values.yaml")
  ]
  depends_on = [helm_release.logstash]
}

resource "helm_release" "jenkins" {
  chart = "jenkins"
  repository = "./charts"
  name = "jenkins"
  version = "1.11.3"
  namespace = "kube-jenkins"
  values = [
    file("./charts/values-store/jenkins-values.yaml")
  ]
  depends_on = [helm_release.filebeat]
}

resource "helm_release" "mysql" {
  chart = "mysql"
  repository = data.helm_repository.stable.metadata[0].name
  name = "mysql"
  version = "1.6.3"
  namespace = "kube-mysql"
  values = [
    file("./charts/values-store/mysql-values.yaml")
  ]
  depends_on = [helm_release.jenkins]
}

resource "helm_release" "nginx-ingress" {
  chart = "nginx-ingress"
  repository = data.helm_repository.stable.metadata[0].name
  name = "nginx-ingress"
  version = "1.36.2"
  namespace = "nginx-ingress"
  values = [
    file("./charts/values-store/nginx-values.yaml")
  ]
  depends_on = [helm_release.mysql]
}

