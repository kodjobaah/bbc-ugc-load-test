aws_acnt_num=$(aws sts get-caller-identity | jq -r '.Account')

POLICY_ARN="arn:aws:iam::$aws_acnt_num:policy/<AmazonEKSClusterAutoscalerPolicy>"
echo $POLICY_ARN
echo $aws_acnt_num
