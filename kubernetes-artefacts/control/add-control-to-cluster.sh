#!/usr/bin/env bash

declare RESULT=($(eksctl utils describe-stacks --cluster jmeterstresstest | grep StackId))  
for i in "${RESULT[@]}"
do
    var="${i%\"}"
    var="${var#\"}"
    if [[ $var == "arn:aws:cloudformation"* ]]; then
        arrIN=(${var//:/ })
        region=${arrIN[3]}
        aws_acnt_num=${arrIN[4]}
    fi
   # do whatever on $i
done

echo $region
echo $aws_acnt_num

POLICY_ARN="arn:aws:iam::$aws_acnt_num:policy/jmeter-workbench-eks-control-policy"
echo $POLICY_ARN
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl create namespace control
eksctl create iamserviceaccount --name afriex-control --namespace control  --cluster jmeterstresstest --attach-policy-arn $POLICY_ARN --approve --override-existing-serviceaccounts
kubectl create -f clusterolebinding.yaml
kubectl create -n control -f control.yaml
kubectl create -n control -f pdb.yaml
