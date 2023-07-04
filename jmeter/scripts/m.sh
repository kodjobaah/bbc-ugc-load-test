ENV="dev"
hostString="aws --region eu-west-3  ec2 describe-instances --profile afriex  --region eu-west-3 | jq -r '.Reservations[].Instances[] | select(.SecurityGroups[] | .GroupName == \"afriex-marketplace-$ENV-bastion\") | .NetworkInterfaces[].PrivateIpAddresses[].Association.PublicDnsName'"
BASTION_HOST=$(eval $hostString)
echo "$BASTION_HOST"

