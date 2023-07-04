#!/bin/bash
#set -x
function checkIfTestNameIsInUse() {
    runningTest=$(kubectl get ns --output json | jq -r '.items[].metadata.name')
    listOfRunningTest=(${runningTest// / })
    for i in "${listOfRunningTest[@]}"
    do
        if [[ $i =~ $1 ]];then
            echo "1"
            return
        fi
    done
    echo "0"
}
           
ENV=$1
SYSTEM_UNDER_TEST="${ENV}.afriexapi.com"
aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
hostString="aws --region eu-west-3  ec2 describe-instances --profile afriex  --region eu-west-3 | jq -r '.Reservations[].Instances[] | select(.SecurityGroups[] | .GroupName == \"afriex-marketplace-$ENV-bastion\") | .NetworkInterfaces[].PrivateIpAddresses[].Association.PublicDnsName'"
BASTION_HOST=$(eval $hostString)
echo "BASTION_HOST=$BASTION_HOST"
databasePassword="aws secretsmanager get-secret-value --secret-id afriex-marketplace-${ENV}-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f1 | cut -d ':' -f3"
DATABASE_PASSWORD=$(eval "$databasePassword")
databaseHost="aws secretsmanager get-secret-value --secret-id afriex-marketplace-${ENV}-ENV --profile afriex --region eu-west-3 | jq --raw-output '.SecretString' | jq -r .DATABASE_URL | cut -d '@' -f2 | cut -d ':' -f1"
DATABASE_HOST=$(eval "$databaseHost")
sed -i '' 's+afriex_jmeter_home+'"/data"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+bastion_ip+'"${BASTION_HOST}"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+afriex_database_host+'"${DATABASE_HOST}"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+afriex_database_password+'"${DATABASE_PASSWORD}"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+afriex_system_under_test+'"${SYSTEM_UNDER_TEST}"'+gi' api/orderFlow/orderFlow.jmx

bastionHostKey="afriex-marketplace-bastion-private-key-${ENV}"
secrets=$(aws  secretsmanager list-secrets --region eu-west-3 --profile afriex --max-items 100 --query 'SecretList[*].ARN' --output text)
listOfSecrets=(${secrets// / })
for i in "${listOfSecrets[@]}"
do
    if [[ $i =~ $bastionHostKey ]];then
        rm -rf "marketplace-bastion-${ENV}.pem"
        aws secretsmanager get-secret-value --secret-id $i --profile afriex --region eu-west-3 --query 'SecretString' | tr -d '"' | base64 --decode > "marketplace-bastion-${ENV}.pem"
        chmod 0400 "marketplace-bastion-${ENV}.pem"
    fi
done

numberOfTests=$(aws s3 ls s3://afriex-jmeter-reports/orderflow/ --summarize  | wc -l)
numberOfTests=$((numberOfTests + 1))
context="orderflow-$numberOfTests"
inUse=$(checkIfTestNameIsInUse $context)
echo "inuse=$inUse"

while [ $inUse == 1 ]
do
    numberOfTests=$((numberOfTests + 1))
    context="orderflow-$numberOfTests"
    inUse=$(checkIfTestNameIsInUse $context)
done

echo $context
aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
host=$(kubectl get svc -n control --output json | jq -r '.items[].status.loadBalancer.ingress[].hostname')
startTestCmd="curl -X POST -F 'jmeter=@api/orderflow/orderFlow.jmx' -F 'data=@marketplace-bastion-${ENV}.pem' -F 'context=$context' -F 'numberOfNodes=1' -F 'xmx=1' -F 'xms=1' -F 'cpu=1' -F 'ram=1' -F 'maxMetaspaceSize=768' $host:1323/start-test"
echo $startTestCmd
eval "$startTestCmd"

sed -i '' 's+afriex_jmeter_home+'"/data"'+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${BASTION_HOST}"'+bastion_ip+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${DATABASE_HOST}"'+afriex_database_host+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${DATABASE_PASSWORD}"'+afriex_database_password+gi' api/orderFlow/orderFlow.jmx
sed -i '' 's+'"${SYSTEM_UNDER_TEST}"'+afriex_system_under_test+gi' api/orderFlow/orderFlow.jmx

curl "$host:1323/test-status" | jq .
