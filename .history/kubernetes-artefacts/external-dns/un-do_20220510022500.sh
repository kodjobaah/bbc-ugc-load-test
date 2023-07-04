#!/usr/bin/env bash

clustername=$(aws eks list-clusters | jq -r '.clusters[]')
echo $clustername

eksctl delete iamserviceaccount --name external-dns --namespace default --cluster "$clustername"

