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
sed -i '' 's+afriex-env+'"${SYSTEM_UNDER_TEST}"'+gi' admin/product/importexport/import.jmx

numberOfTests=$(aws s3 ls s3://afriex-jmeter-reports/importexport/ --summarize  | wc -l)
numberOfTests=$((numberOfTests))
context="importexport-$numberOfTests"
inUse=$(checkIfTestNameIsInUse $context)
echo "inuse=$inUse"

while [ $inUse == 1 ]
do
    numberOfTests=$((numberOfTests + 1))
    context="importexport-$numberOfTests"
    inUse=$(checkIfTestNameIsInUse $context)
done

aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
host=$(kubectl get svc -n control --output json | jq -r '.items[].status.loadBalancer.ingress[].hostname')
startTestCmd="curl -X POST -F 'jmeter=@admin/product/importexport/import.jmx' -F 'data=@admin/product/importexport/data/create.csv' -F 'context=$context' -F 'numberOfNodes=1' -F 'xmx=1' -F 'xms=1' -F 'cpu=1' -F 'ram=1' -F 'maxMetaspaceSize=768' $host:1323/start-test"
echo $startTestCmd
eval "$startTestCmd"
sed -i '' 's+'"${SYSTEM_UNDER_TEST}"'+afriex_system_under_test+gi' admin/product/importexport/import.jmx
curl "$host:1323/test-status" | jq .