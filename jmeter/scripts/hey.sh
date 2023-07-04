#!/bin/bash

command="aws secretsmanager get-secret-value --secret-id afriex-marketplace-$1-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f1 | cut -d ':' -f3"
echo $command
out=$(eval "$command")
echo "$out"
