#!/bin/bash
AMI_ID="ami-0055977a6e828a4f4"
SECURITY_GROUP_ID="sg-03326489dae6d8836"

for INSTANCE in $@
do
aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]' \
    --query 'Instances[*].PrivateIpAddress' \
    --output text
done    