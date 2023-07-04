#!/bin/bash

aws iam create-policy --policy-name jmeterstresstest_efs_csi_driver_policy --policy-document file://efs-iam-policy.json
eksctl create iamserviceaccount --name efs-csi-controller-sa --namespace kube-system --cluster jmeterstresstest  --attach-policy-arn arn:aws:iam::625194385885:policy/jmeterstresstest_efs_csi_driver_policy  --approve --override-existing-serviceaccounts --region eu-west-3
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3"

