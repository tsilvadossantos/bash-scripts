#!/bin/env bash

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION=<region>

#Run a particular command in target instances
aws ec2 describe-instances --query \
'Reservations[].Instances[].[ InstanceId,[Tags[?Key==`Name`].Value][0][0],State.Name,InstanceType,Placement.AvailabilityZone,Environment ]' \
--output text | \
grep 'target' | \
awk '{print $1}' | \
while read line
do

  for i in `aws ec2 describe-instances --instance-ids $line --query 'Reservations[].Instances[].PrivateIpAddress' --output text`
  do
    ssh -Tn <user>@$i -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '<COMMAND>'
  done

done
