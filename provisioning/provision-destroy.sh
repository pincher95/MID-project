#!/usr/bin/env bash
#Due to bug in Terraform destory this is custom provisioned resources destroy

echo "Gathering and uninstalling deployed charts..."
for i in {nginx-ingress,kube-logging,kube-metrics,kube-consul,kube-jenkins,kube-app}; do
  helm list -n $i |awk '{print $1}' |grep -vi name |xargs helm uninstall -n $i
  done

echo -e "\nDeleting Terraform state..."
terraform destroy -auto-approve