#!/usr/bin/env bash

# we need to retrieve the latest docker image available for our EKS version
export K8S_VERSION=$(kubectl version -o json | jq -r '.serverVersion.gitVersion | (sub("\\-.*";""))')
echo "$K8S_VERSION"
#export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

export AUTOSCALER_VERSION=$( curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | jq  -r '.[] | select( .tag_name | contains("cluster-autoscaler-1"))| .tag_name' | head -n 1)
echo "$AUTOSCALER_VERSION"
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v1.22.0
