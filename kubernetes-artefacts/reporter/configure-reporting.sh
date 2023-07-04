#!/usr/bin/env bash
working_dir=`pwd`

## Create jmeter database automatically in Influxdb

echo "Creating Influxdb jmeter Database"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`kubectl get po -n afriex-reporter | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=`kubectl get po -n afriex-reporter | grep influxdb-jmeter | awk '{print $1}'`
kubectl exec -ti -n afriex-reporter $influxdb_pod -- influx -execute 'CREATE DATABASE jmeterstresstest'
kubectl exec -ti -n afriex-reporter $influxdb_pod -- influx -execute 'CREATE USER admin WITH PASSWORD 'admin' WITH ALL PRIVILEGES'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"
grafana_pod=`kubectl get po -n afriex-reporter | grep jmeter-grafana | awk '{print $1}'`

wget  --header 'Accept: application/json' --header 'Content-Type: application/json;charset=UTF-8' --post-data '{}' 'http://admin:admin@127.0.0.1:3000/api/datasources/1/enable-permissions

kubectl exec -ti -n afriex-reporter $grafana_pod -- wget  --header 'Content-Type: application/json;charset=UTF-8' --post-data '{"name":"jmeterdb","type":"influxdb","url":"http://influxdb-jmeter:8086","access":"proxy","isDefault":true,"database":"jmeterstresstest","user":"admin","password":"admin"}' 'http://admin:admin@127.0.0.1:3000/api/datasources'
