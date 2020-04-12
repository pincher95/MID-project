output "k8s_node_IP" {
  value = data.aws_eks_cluster.cluster.vpc_config
}