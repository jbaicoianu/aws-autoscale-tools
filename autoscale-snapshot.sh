#!/bin/sh

INSTANCEID=$1
NAME=$2
AUTOSCALENAME=$3
INSTANCETYPE=t2.micro
SECURITYGROUPS=sg-245c9d5c
KEYNAME=JanusVR


IMAGEID=$(aws ec2 create-image --instance-id $INSTANCEID --name $NAME --output text)
if [ ! -z $IMAGEID ]; then
  echo $IMAGEID
  aws autoscaling create-launch-configuration --launch-configuration-name $NAME --image-id $IMAGEID --instance-type $INSTANCETYPE --security-groups $SECURITYGROUPS --key-name $KEYNAME --iam-instance-profile aws-elasticbeanstalk-ec2-role 
  echo aws autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTOSCALENAME --launch-configuration-name $NAME
  aws autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTOSCALENAME --launch-configuration-name $NAME
else
  echo No valid AMI ID, exiting
fi

