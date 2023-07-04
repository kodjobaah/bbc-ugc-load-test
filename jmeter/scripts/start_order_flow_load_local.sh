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

