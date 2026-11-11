#!/bin/bash
AMI_ID="ami-0055977a6e828a4f4"
SECURITY_GROUP_ID="sg-03326489dae6d8836"

for instance in $@
do
instance_id=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SECURITY_GROUP_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

    if ["$instance" == "frontend"] ; then
        ip=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
    else
        ip=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text)
    fi
    echo "ip is $ip $instance "    
done    