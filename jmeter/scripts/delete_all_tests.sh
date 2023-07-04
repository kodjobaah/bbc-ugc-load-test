aws eks --region eu-west-3 update-kubeconfig --name jmeterstresstest
host=$(kubectl get svc -n control --output json | jq -r '.items[].status.loadBalancer.ingress[].hostname')
runningTest=$(kubectl get ns --output json | jq -r '.items[].metadata.name')
listOfRunningTest=(${runningTest// / })
for i in "${listOfRunningTest[@]}"
do
    if [[ $i != "control" ]] && [[ $i != "default" ]] && [[ $i != "kube"* ]] && [[ $i != "afriex-reporter" ]] ;then
        startTestCmd="curl -v -X POST  -F 'TenantContext=$i' $host:1323/delete-tenant"
        echo $startTestCmd
        eval "$startTestCmd"

    fi
done
curl "$host:1323/test-status" | jq .
echo "0"