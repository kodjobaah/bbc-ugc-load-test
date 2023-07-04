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

rm -rf test-scripts
cp -R ../../test-scripts .
rm -rf tenant
cp -R ../../kubernetes-artefacts/tenant .
rm -rf test 
cp -R ../../src/test .
rm -rf config
cp -R ../../config .
rm -rf data
cp -R ../../data .
rm -rf admin
mkdir admin

cp -R ../../admin/cmd admin
cp -R ../../admin/internal admin
cp -R ../../admin/configs admin
cp -R ../../admin/web admin
cp -R ../../admin/go.mod admin
cp -R ../../admin/go.sum admin

rm -rf test-admin
mkdir test-admin
cp -R ../../test-admin/src test-admin
cp -R ../../test-admin/package* test-admin
cp -R ../../test-admin/public test-admin
cd test-admin
npm install
yarn build
cd ..
cp -R test-admin/build admin/web


REPO="$aws_acnt_num.dkr.ecr.$region.amazonaws.com/jmeterstresstest/control:latest"
aws ecr delete-repository --force --repository-name jmeterstresstest/control
aws ecr create-repository --repository-name jmeterstresstest/control
docker build --platform amd64 -t jmeterstresstest/control .
docker tag jmeterstresstest/control:latest $REPO
docker push $REPO
