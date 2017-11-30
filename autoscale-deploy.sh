#!/bin/sh

source ./autoscale-functions.sh

INSTANCETYPE=t2.micro

groupname=$1
instanceid=$2
securitygroups=$3
keypairname=$4
iamrole=$5

datestr=$(date +"%m-%d-%y_%H%M%S")
aminame=${groupname}_${datestr}

if [ -z $securitygroups ]; then
  securitygroups=$(get_securitygroups_from_instance $instanceid)
fi
if [ -z $keypairname ]; then
  keypairname=$(get_keyname_from_instance $instanceid)
fi
if [ -z $iamrole ]; then
  iamrole="aws-elasticbeanstalk-ec2-role" #$(get_iamrole_from_instance $instanceid)
fi

echo -n "Make new AMI \"$aminame\" image from instance \"$instanceid\"? [Y/n] "
read makeami
if [ "$makeami" = "y" ] || [ "$makeami" = "Y" ] || [ "$makeami" = "" ]; then
  echo -n Tagging new AMI \"$aminame\"...
  amiid=$(aws ec2 create-image --instance-id "$instanceid" --name "$aminame" --output text)
  if [ ! -z $amiid ]; then
    echo "done, AMI id is $amiid"

    echo -n Creating launch configuration...
    aws autoscaling create-launch-configuration --launch-configuration-name "$aminame" --image-id $amiid --instance-type $INSTANCETYPE --security-groups "$securitygroups" --key-name "$keypairname" --iam-instance-profile "$iamrole"
    echo done
    echo -n Updating autoscaling group...
    aws autoscaling update-auto-scaling-group --auto-scaling-group-name $groupname --launch-configuration-name $aminame
    echo done

    echo -n "Terminate staging instance? [Y/n] "
    read terminate
    if [ "$terminate" = "y" ] || [ "$terminate" = "Y" ] || [ "$terminate" = "" ]; then

      imagestatus=$(aws ec2 describe-images --image-ids $amiid --query Images[0].State --output text)
      if [ $imagestatus != "available" ]; then
        echo -n "Waiting for image creation to finish."
        while [ $imagestatus != "available" ]; do
          imagestatus=$(aws ec2 describe-images --image-ids $amiid --query Images[0].State --output text)
          echo -n .
          sleep 5
        done
        echo done
      fi

      echo -n "Terminating instance \"$instanceid\"..."
      terminated=$(aws ec2 terminate-instances --instance-ids $instanceid)
      echo done
    else
      show_shutdown_message "$instanceid"
    fi
    ./autoscale-rollingupdate.sh "$groupname"
  else
    echo No valid AMI ID, exiting
  fi
else
  show_shutdown_message "$instanceid"
fi


