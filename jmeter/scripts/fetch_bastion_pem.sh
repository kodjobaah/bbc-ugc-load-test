#!/usr/bin/env bash

bastionHostKey="afriex-marketplace-bastion-private-key-$1"
secrets=$(aws  secretsmanager list-secrets --region eu-west-3 --profile afriex --max-items 100 --query 'SecretList[*].ARN' --output text)
listOfSecrets=(${secrets// / })
for i in "${listOfSecrets[@]}"
do
    if [[ $i =~ $bastionHostKey ]];then
        rm -rf marketplace-bastion-dev.pem
        aws secretsmanager get-secret-value --secret-id $i --profile afriex --region eu-west-3 --query 'SecretString' | tr -d '"' | base64 --decode > marketplace-bastion-dev.pem
        chmod 0400 marketplace-bastion-dev.pem
    fi
done
