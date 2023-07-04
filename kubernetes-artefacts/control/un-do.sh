#!/usr/bin/env bash

kubectl delete -f clusterolebinding.yaml
kubectl delete namespace control
eksctl delete iamserviceaccount --name  afriex-control --namespace control --cluster jmeterstresstest
