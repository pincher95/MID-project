output "k8s_node_IP" {
  value = data.aws_eks_cluster.cluster.vpc_config
}

//output "delay" {
//  value = kubernetes_namespace.kube-namespaces[length(var.namespaces) - 1 ].id
//}