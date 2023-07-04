#!/bin/bash

#!/usr/bin/env bash

function getInstanceId {
    env=$1
    instanceId="aws --region eu-west-3  ec2 describe-instances --profile afriex  --region eu-west-3 | jq -r '.Reservations[].Instances[] | select(.SecurityGroups[] | .GroupName == \"afriex-marketplace-$env-bastion\") | .InstanceId'"
    id=$(eval $instanceId)
    echo $id
}

function getStatus {
    id=$1
    instanceStatus="aws ec2 describe-instance-status --instance-id $id --profile afriex --region eu-west-3 | jq -r '.InstanceStatuses[].InstanceStatus.Details[].Status'"
    status=$(eval $instanceStatus)
    echo $status
}

env=$1
bastionHostKey="afriex-marketplace-bastion-private-key-$1"
secrets=$(aws  secretsmanager list-secrets --region eu-west-3 --profile afriex --max-items 100 --query 'SecretList[*].ARN' --output text)
listOfSecrets=(${secrets// / })
for i in "${listOfSecrets[@]}"
do
    if [[ $i =~ $bastionHostKey ]];then
        rm -rf marketplace-bastion-dev.pem
        aws secretsmanager get-secret-value --secret-id $i --profile afriex --region eu-west-3 --query 'SecretString' | tr -d '"' | base64 --decode > "marketplace-bastion-$env.pem"
        chmod 0400 "marketplace-bastion-$env.pem"
    fi
done

id=$(getInstanceId "$env")
echo "$id"

status=$(getStatus "$id")
echo "current status=$status"
running="running"
if [ "$status" != "$running" ]; then
    rebootCmd="aws ec2 reboot-instances --instance-ids $id --profile afriex --region eu-west-3"
    echo "rebootCmd=$rebootCmd"
    reboot=$(eval "$rebootCmd")
    echo "reboot=$reboot"
    if [[ -z $reboot ]]; then
        for (( c=1; c<=10; c++ ))
        do
            status=$(getStatus "$id")
            echo "current status=$status"
            if [ "$status" != "$running" ]; then
                sleep 10s
            else
                break
            fi
        done;

    fi
fi
bastionHost=" aws --region eu-west-3  ec2 describe-instances --profile afriex  --region eu-west-3 | jq -r '.Reservations[].Instances[] | select(.SecurityGroups[] | .GroupName == \"afriex-marketplace-$env-bastion\") | .NetworkInterfaces[].PrivateIpAddresses[].Association.PublicDnsName'"
c=$(eval "$bastionHost")
echo "bastionHost=$c"
ssh -D 1080 -i "marketplace-bastion-dev.pem" "ubuntu@$c"

10.3.1.27 - - [30/Nov/2021:00:41:48 +0000] "POST /api/v2/shop/orders HTTP/1.1" 201 5774 "-" "Apache-HttpClient/4.5.12 (Java/1.8.0_282)"
[ip, date, action, url, status > 201]
