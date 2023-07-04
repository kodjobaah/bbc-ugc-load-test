#!/usr/bin/env bash

eksctl delete cluster -f cluster.yaml
JMETER_POLICY_ARN="arn:aws:iam::$1:policy/jmeter-workbench-eks-jmeter-policy"
echo $JMETER_POLICY_ARN
aws iam delete-policy --policy-arn $JMETER_POLICY_ARN
CONTROL_POLICY_ARN="arn:aws:iam::$1:policy/jmeter-workbench-eks-control-policy"
echo $CONTROL_POLICY_ARN
aws iam delete-policy --policy-arn $CONTROL_POLICY_ARN
