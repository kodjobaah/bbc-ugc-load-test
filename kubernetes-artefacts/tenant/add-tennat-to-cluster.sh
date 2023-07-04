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

POLICY_ARN="arn:aws:iam::$aws_acnt_num:policy/afriex-eks-jmeter-policy"
echo $POLICY_ARN
kubectl create namespace $1 
eksctl create iamserviceaccount --name afriex-jmeter --namespace $1  --cluster jmeterstresstest --attach-policy-arn $POLICY_ARN --approve --override-existing-serviceaccounts
cat jmeter-slaves.yaml.template | awk -v "act_num=$aws_acnt_num" '{gsub(/AWS_ACCOUNT_NUMBER/,act_num)}1' | awk -v "region=$region" '{gsub(/AWS_REGION/,region)}1' > jmeter-slaves.yaml
cat jmeter-master.yaml.template | awk -v "act_num=$aws_acnt_num" '{gsub(/AWS_ACCOUNT_NUMBER/,act_num)}1' | awk -v "region=$region" '{gsub(/AWS_REGION/,region)}1' > jmeter-master.yaml

kubectl create -n $1 -f jmeter-master.yaml
kubectl create -n $1 -f jmeter-slaves.yaml