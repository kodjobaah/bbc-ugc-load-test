#!/usr/bin/env bash

eksctl delete iamserviceaccount --name afriex-jmeter --namespace $1 --cluster jmeterstresstest
kubectl delete namespace $1 
