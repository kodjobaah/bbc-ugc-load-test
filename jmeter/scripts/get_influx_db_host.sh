#!/usr/bin/env bash
 influxdb=$(kubectl get svc -n afriex-reporter --output json | jq -r '.items[]| select(.metadata.name == "influxdb-jmeter")| .status.loadBalancer.ingress[].hostname')
 echo "$influxdb"