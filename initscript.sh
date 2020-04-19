#!/usr/bin/env bash

WORKING_DIR=$(pwd)
case "$1" in
  apply)
    echo -e "Deploying Infra via Terrafom.....\n"
    cd $WORKING_DIR/infra/dev
    terraform init &> /dev/null
    terraform plan &> /dev/null
    terraform apply -auto-approve |grep -i "Apply complete" -A5 #2>&1 /dev/null
    cat ${WORKING_DIR}/kubeconfig > ~/.kube/config
    echo -e "\nProvisioning resources via Terrafom.....\n"
    cd $WORKING_DIR/provisioning
    terraform init &> /dev/null
    terraform plan &> /dev/null
    terraform apply -auto-approve |grep -i "Apply complete" -A5
    ;;
  destroy)
    echo -e "Destroying provisioned resources...\n"
    cd $WORKING_DIR/provisioning
    ./provision-destroy.sh
    cd $WORKING_DIR/infra/dev
    terraform destroy -auto-approve
    ;;
  *)
    echo -e "Usage: $0 [apply|destroy]"
    exit 1
    ;;
esac


