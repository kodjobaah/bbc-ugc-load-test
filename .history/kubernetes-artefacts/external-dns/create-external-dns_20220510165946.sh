#!/usr/bin/env bash

clustername=$(aws eks list-clusters | jq -r '.clusters[]')
echo $clustername
POLICY_NAME="$clustername-external-dns-policy"
POLICY_ARN="arn:aws:iam::625194385885:policy/jmeterstresstest-external-dns-policy"
aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://iam-permisson.json
eksctl create iamserviceaccount  --cluster="$clustername" --namespace=default  --name=external-dns  --attach-policy-arn="$POLICY_ARN" --override-existing-serviceaccounts --approve

 deployment.yaml
cluster-role-bindings.yaml