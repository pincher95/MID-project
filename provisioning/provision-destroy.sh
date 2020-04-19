#!/usr/bin/env bash
#Due to bug in Terraform destory this is custom provisioned resources destroy
NAMESPACES=$(kubectl get namespaces |grep -vi 'default\|kube-system\|name' |awk '{print $1}')

echo "Gathering and uninstalling deployed charts..."
for namespace in ${NAMESPACES}; do
  helm list -n ${namespace} |awk '{print $1}' |grep -vi name |xargs helm uninstall -n ${namespace}
  done

echo -e "\nDeleting Terraform state..."
terraform destroy -auto-approve