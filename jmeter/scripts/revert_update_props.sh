#!/usr/bin/env bash

ENV=$1
aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
BASTION_HOST=$(kubectl get svc -n control --output json | jq -r '.items[].status.loadBalancer.ingress[].hostname')

databasePassword="aws secretsmanager get-secret-value --secret-id afriex-marketplace-$ENV-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f1 | cut -d ':' -f3"
DATABASE_PASSWORD=$(eval "$databasePassword")
databaseHost="aws secretsmanager get-secret-value --secret-id afriex-marketplace-$ENV-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f2 | cut -d ':' -f1"
DATABASE_HOST=$(eval "$databaseHost")
sed -i '' 's+'"/data"'+afriex_jmeter_home+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"/data"'+bastion_ip+'"/data"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${DATABASE_HOST}"'+afriex_database_host+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${DATABASE_PASSWORD}"'+afriex_database_password+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${SYSTEM_UNDER_TEST}"'+afriex_system_under_test+gi' api/orderFlow/orderFlow.jmx