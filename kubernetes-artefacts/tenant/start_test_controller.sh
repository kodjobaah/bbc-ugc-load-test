#!/usr/bin/env bash

if [[ ! -z "$AWS_ROLE_ARN" ]]; 
then
   uuid=$(python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)')

   aws sts assume-role-with-web-identity --role-arn $AWS_ROLE_ARN --role-session-name mh9test --web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE --duration-second 3600  > "/tmp/$uuid.txt"
   aak='cat /tmp/$uuid.txt | jq -r ".Credentials.AccessKeyId"'
   sak='cat /tmp/$uuid.txt | jq -r ".Credentials.SecretAccessKey"'
   st='cat /tmp/$uuid.txt | jq -r ".Credentials.SessionToken"'
   export AWS_ACCESS_KEY_ID=$(eval "$aak")
   export AWS_SECRET_ACCESS_KEY=$(eval "$sak")
   export AWS_SESSION_TOKEN=$(eval "$st")
   export AWS_DEFAULT_REGION=eu-west-3
   rm "/tmp/$uuid.txt"
fi


working_dir="/home/control"
#working_dir="/Users/baahk01/workspace/github.com/afriexUK/afriex-jmeter-testbencher-test-kubernettes"

echo "ork = $working_dir"

jmx="$working_dir/src/test/$1"
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found: $jmx"
    echo "Kindly check and input the correct file path"
    exit
fi

working_dir="/home/control"
IFS=$'\n'


test_to_run="$1"
master_pod=`kubectl get po -n $2 | grep jmeter-master | awk '{print $1}'`

# Copy test to master
path=${test_to_run%/*} 
root=$(echo "$path" | cut -d "/" -f1)
kubectl exec -it -n $2 $master_pod  -- bash -c "rm -rf test/$root"
kubectl exec -it -n $2 $master_pod  -- bash -c "mkdir test/$path" 
kubectl cp "$working_dir/src/test/$test_to_run" "$master_pod:/home/jmeter/test/$path" -n $2
echo "Starting Jmeter load test $test_to_run for $2 running on $master_pod for the following slaves $3 "

kubectl exec -it -n $2 $master_pod -- bash -c "/home/jmeter/bin/load_test.sh /home/jmeter/test/$test_to_run $2 $3" 
