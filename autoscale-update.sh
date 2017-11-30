#!/bin/sh

INSTANCETYPE=t2.micro
groupname=$1
instanceid=$2

source ./autoscale-functions.sh
  
echo -n "Gathering information about scaling group \"$groupname\""
# Figure out the current settings for the currently-running active scaling group
amiid=$(get_ami_for_autoscaling_group $1)
echo -n .
securitygroups="sg-245c9d5c" #$(get_securitygroups_for_autoscaling_group $1)
echo -n .
keypairname=$(get_keypairname_for_autoscaling_group $1)
echo -n .
iamrole=$(get_iamrole_for_autoscaling_group $1)
echo done
echo "Scaling group \"$groupname\" is currently using $AMI \"$amiid\" ($securitygroups $keypairname $iamrole)"

# Prompt user to spin up a new instance, so they can make any changes necessary.  When they're done, we'll ask them if they're ready to deploy their changes.
echo -n "Launch staging instance? [Y/n] "
read launch
if [ "$launch" = "y" ] || [ "$launch" = "Y" ] || [ "$launch" = "" ]; then
  echo -n "Launching new $INSTANCETYPE instance... "
  instancename="${groupname}-staging"
  # FIXME - should send --iam-instance-profile but need to figure out dumb syntax, which is different from the autoscaling syntax below
  instanceid=$(aws ec2 run-instances --instance-type $INSTANCETYPE --image-id $amiid --security-group-ids $securitygroups --key-name "$keypairname" --query Instances[0].InstanceId --output text)
  if [ ! -z "$instanceid" ]; then
    echo $instanceid
    # Spin up an instance, then wait for a response from Amazon indicating status is "ok"
    echo -n "Waiting for instance to be fulfilled"
    aws ec2 create-tags --resources "$instanceid" --tags Key=Name,Value="$instancename"

    response="None"
    while [ "$response" = "None" ]; do
      # There's a short period of time between when we submit the request and when AWS will give us info.  Wait until we start getting real info before continuing
      echo -n .
      response=$(aws ec2 describe-instance-status --instance-ids "$instanceid" --query InstanceStatuses[0].InstanceStatus.Status --output text)
      sleep 5
    done
    if [ "$response" = "initializing" ]; then
      #echo -n "done"
      #while [ $response = "initializing" ]; do
      #  echo -n .
      #  response=$(aws ec2 describe-instance-status --instance-ids "$instanceid" --query InstanceStatuses[0].InstanceStatus.Status --output text)
      #  sleep 5
      #done

      #if [ $response = 'ok' ]; then
        echo "done!"
        hostname=$(aws ec2 describe-instances --instance-ids "$instanceid" --query Reservations[0].Instances[0].PublicDnsName --output text)
        echo "Will now connect to $hostname via SSH.  You can establish your own connection to this server with the following command:"
	echo
	echo "    ssh ec2-user@$hostname"
	echo
	echo "Log out when system is ready for the next step."
	echo
	echo -n "Establishing connection."
	SSHSUCCESS=0
	while [ $SSHSUCCESS -eq 0 ]; do
		sleep 2
		echo -n .
        	ssh -q -o "StrictHostKeyChecking=no" ec2-user@$hostname && SSHSUCCESS=1
	done

	echo
	echo "done!"
	echo

        ./autoscale-deploy.sh $groupname $instanceid $securitygroups $keypairname $iamrole

      #else
      #  echo "ERROR - unexpected status \"$response\" for instance \"$instanceid\""
      #fi
    else
      echo "ERROR - unexpected status \"$response\" for instance \"$instanceid\""
    fi
  else
    echo "Failed to spin up instance for some reason!"
  fi
else
  echo "aborted"
fi
