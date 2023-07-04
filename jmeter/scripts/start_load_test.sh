#!/bin/bash

function checkIfTestNameIsInUse() {
    runningTest=$(kubectl get ns --output json | jq -r '.items[].metadata.name')
    listOfRunningTest=(${runningTest// / })
    for i in "${listOfRunningTest[@]}"
    do
        if [[ $i =~ $1 ]];then
            echo 1
        fi
    done
    echo 0
}

ENV=$1
aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
BASTION_HOST=$(kubectl get svc -n control --output json | jq -r '.items[].status.loadBalancer.ingress[].hostname')

databasePassword="aws secretsmanager get-secret-value --secret-id afriex-marketplace-$ENV-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f1 | cut -d ':' -f3"
DATABASE_PASSWORD=$(eval "$databasePassword")
databaseHost="aws secretsmanager get-secret-value --secret-id afriex-marketplace-$ENV-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f2 | cut -d ':' -f1"
DATABASE_HOST=$(eval "$databaseHost")
sed -i '' 's+afriex_jmeter_home+'"/data"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+bastion_ip+'"${BASTION_HOST}"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+afriex_database_host+'"${DATABASE_HOST}"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+afriex_database_password+'"${DATABASE_PASSWORD}"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+afriex-env+'"${ENV}"'+gi' src/test/jmeter/orderFlow.jmx

           
bastionHostKey="afriex-marketplace-bastion-private-key-$ENV"
secrets=$(aws  secretsmanager list-secrets --region eu-west-3 --profile afriex --max-items 100 --query 'SecretList[*].ARN' --output text)
listOfSecrets=(${secrets// / })
for i in "${listOfSecrets[@]}"
do
    if [[ $i =~ $bastionHostKey ]];then
        rm -rf marketplace-bastion-dev.pem
        aws secretsmanager get-secret-value --secret-id $ENV --profile afriex --region eu-west-3 --query 'SecretString' | tr -d '"' | base64 --decode > marketplace-bastion-dev.pem
        chmod 0400 marketplace-bastion-dev.pem
    fi
done

numberOfTests=$(aws s3 ls s3://afriex-jmeter-reports/orderflow/ --summarize  | wc -l)
numberOfTests=$((numberOfTests - 2))
context="orderflow-$numberOfTests"

inUse=$(checkIfTestNameIsInUse $context)
while [ $inUse -gt 0 ]
do
    numberOfTests=$((numberOfTests + 1))
    context="orderflow-$numberOfTests"
    inUse=$(checkIfTestNameIsInUse $context)
done

aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
host=$(kubectl get svc -n control --output json | jq -r '.items[].status.loadBalancer.ingress[].hostname')
startTestCmd="curl -v -X POST -F 'jmeter=@api/orderflow/orderFlow.jmx' -F 'data=@marketplace-bastion-dev.pem' -F 'context=$context' -F 'numberOfNodes=1' -F 'xmx=1' -F 'xms=1' -F 'cpu=1' -F 'ram=1' -F 'maxMetaspaceSize=768' $host:1323/start-test"
echo $startTestCmd
eval "$startTestCmd"