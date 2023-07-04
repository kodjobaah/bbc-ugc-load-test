#!/usr/bin/env bash

declare RESULT=($(eksctl utils describe-stacks --cluster jmeterstresstest | grep StackId))  
for i in "${RESULT[@]}"
do
    var="${i%\"}"
    var="${var#\"}"
    if [[ $var == "arn:aws:cloudformation"* ]]; then
        arrIN=(${var//:/ })
        region=${arrIN[3]}
        aws_acnt_num=${arrIN[4]}
    fi
   # do whatever on $i
done

echo $region
echo $aws_acnt_num

rm -rf src
cp -R ../../src .
rm -rf jmeter-master
cp -R ../../jmeter-master .
REPO="$aws_acnt_num.dkr.ecr.$region.amazonaws.com/jmeterstresstest/jmeter-master:latest"
echo "Repo: $REPO"
aws ecr delete-repository --force --repository-name jmeterstresstest/jmeter-master
aws ecr create-repository --repository-name jmeterstresstest/jmeter-master
docker build --platform amd64  -t jmeterstresstest/jmeter-master .
docker tag jmeterstresstest/jmeter-master:latest $REPO
docker push $REPO 
