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

POLICY_ARN="arn:aws:iam::$aws_acnt_num:policy/jmeter-workbench-eks-jmeter-policy"
echo $POLICY_ARN
kubectl create namespace afriex-reporter
eksctl create iamserviceaccount --name afriex-jmeter --namespace afriex-reporter --cluster jmeterstresstest --attach-policy-arn $POLICY_ARN --approve --override-existing-serviceaccounts
kubectl create -n afriex-reporter -f ./influxdb-sc.yaml
kubectl create -n afriex-reporter -f ./influxdb-pv.yaml
kubectl create -n afriex-reporter -f ./influxdb-pvc.yaml
kubectl create -n afriex-reporter -f ./influxdb-config.yaml
kubectl create -n afriex-reporter -f ./influxdb.yaml
kubectl create -n afriex-reporter -f ./chronograf-sc.yaml
kubectl create -n afriex-reporter -f ./chronograf-pv.yaml  
kubectl create -n afriex-reporter -f ./chronograf-pvc.yaml             
kubectl create -n afriex-reporter -f ./chronograf.yaml             
kubectl create -n afriex-reporter -f ./chronograf-pdb.yaml
kubectl create -n afriex-reporter -f ./grafana-sc.yaml
kubectl create -n afriex-reporter -f ./grafana-pv.yaml
kubectl create -n afriex-reporter -f ./grafana-pvc.yaml
kubectl create -n afriex-reporter -f ./grafana-config.yaml
kubectl create -n afriex-reporter -f ./grafana.yaml
kubectl create -n afriex-reporter -f ./grafana-pdb.yaml
