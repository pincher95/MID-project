#!/usr/bin/env bash

DataList=("alertmanagers"  "podmonitors"  "prometheuses"  "prometheusrules"  "servicemonitors"  "thanosrulers")

echo "Deploying prometheus-operator CRD's"
for val in ${DataList[*]}; do
     kubectl apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/release-0.37/example/prometheus-operator-crd/monitoring.coreos.com_${val}.yaml --validate=false
done