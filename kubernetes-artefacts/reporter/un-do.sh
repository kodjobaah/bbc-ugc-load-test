#!/usr/bin/env bash

kubectl delete namespace afriex-reporter
eksctl delete iamserviceaccount --name afriex-jmeter --namespace afriex-reporter --cluster jmeterstresstest
kubectl delete -f influxdb-pv.yaml -n afriex-reporter
kubectl delete -f influxdb-sc.yaml -n afriex-reporter
kubectl delete -f chronograf-pv.yaml -n afriex-reporter
kubectl delete -f chronograf-sc.yaml -n afriex-reporter
kubectl delete -f grafana-pv.yaml -n afriex-reporter
kubectl delete -f grafana-sc.yaml -n afriex-reporter

