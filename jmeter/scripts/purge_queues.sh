#!/usr/bin/env bash


if [ $# -eq 0 ]; then
    echo "Please provide the environment <dev, stage, prod>"
    exit 1
fi

env="$1"
queues=$(aws sqs list-queues --profile afriex --region eu-west-3 --query 'QueueUrls[*]' --output text)
listOfQueues=(${queues// / })
for i in "${listOfQueues[@]}"
do
    if [[ "$i" == *"$env"*  && "$i" != *"legolas"* ]];then
        echo "$i"
        response=$(aws sqs purge-queue --queue-url "$i" --profile afriex --region eu-west-3)
        echo "$response"
    fi
done
