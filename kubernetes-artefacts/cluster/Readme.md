
Cluster Autoscaler:
Follow the instructions in here:
https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html


After installing the autoscaller add the clustername:
 kubectl edit deployment cluster-autoscaler -n kube-system

--balance-similar-node-groups
--skip-nodes-with-system-pods=false
You also need to change the expander configuration. Search for - --expander= and replace least-waste with random

kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

1.22.1

Follow these instructions for use with the instance selector
https://github.com/aws/amazon-ec2-instance-selector

This is another tool, that is very useful for looking at kubernetes
https://codeberg.org/hjacobs/kube-ops-view


