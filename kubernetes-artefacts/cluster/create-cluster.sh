#!/usr/bin/env bash

aws_acnt_num=$(aws sts get-caller-identity | jq -r '.Account')


aws iam create-policy --policy-name jmeter-workbench-eks-jmeter-policy --policy-document file://./i-am-policy-jmeter.json
aws iam create-policy --policy-name jmeter-workbench-eks-control-policy --policy-document file://./i-am-policy-control.json
eksctl create cluster -f cluster.yaml

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
kubectl create -f csi-storage-class.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

clustername=$(aws eks list-clusters | jq -r '.clusters[]')

POLICY_NAME="$clustername-cluster-autocscaler-policy"
POLICY_ARN="arn:aws:iam::$aws_acnt_num:policy/$POLICY_NAME"
aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://cluster-autoscaler-policy.json
eksctl create iamserviceaccount  --cluster="$clustername" --namespace=kube-system --name=cluster-autoscaler --attach-policy-arn="$POLICY_ARN" --override-existing-serviceaccounts --approve
kubectl apply -f cluster-autoscaler-autodiscover.yaml

# we need to retrieve the latest docker image available for our EKS version
export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

kubectl -n kube-system \
    set image deployment.apps/cluster-autoscaler \
    cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}

kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v1.22.0