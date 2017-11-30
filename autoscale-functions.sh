#!/bin/sh

get_ami_for_autoscaling_group() {
  groupname=$1
  launchconfig=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $groupname --query AutoScalingGroups[0].LaunchConfigurationName --output text)
  aws autoscaling describe-launch-configurations --launch-configuration-names $launchconfig --query LaunchConfigurations[0].ImageId --output text
}
get_securitygroups_for_autoscaling_group() {
  groupname=$1
  launchconfig=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $groupname --query AutoScalingGroups[0].LaunchConfigurationName --output text)
  aws autoscaling describe-launch-configurations --launch-configuration-names "$launchconfig" --query LaunchConfigurations[0].SecurityGroups --output text
}
get_keypairname_for_autoscaling_group() {
  groupname=$1
  launchconfig=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $groupname --query AutoScalingGroups[0].LaunchConfigurationName --output text)
  aws autoscaling describe-launch-configurations --launch-configuration-names "$launchconfig" --query LaunchConfigurations[0].KeyName --output text
}
get_iamrole_for_autoscaling_group() {
  groupname=$1
  launchconfig=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $groupname --query AutoScalingGroups[0].LaunchConfigurationName --output text)
  aws autoscaling describe-launch-configurations --launch-configuration-names "$launchconfig" --query LaunchConfigurations[0].IamInstanceProfile --output text
}
get_keyname_from_instance() {
  instanceid=$1
  aws ec2 describe-instances --instance-ids $instances --query Reservations[0].Instances[0].KeyName --output text
}
get_iamrole_from_instance() {
  instanceid=$1
  aws ec2 describe-instances --instance-ids $instances --query Reservations[0].Instances[0].IamInstanceProfile --output text
}
get_securitygroups_from_instance() {
  instanceid=$1
  aws ec2 describe-instances --instance-ids $instances --query Reservations[0].Instances[0].SecurityGroups[0].GroupId --output text
}

show_shutdown_message() {
  instanceid=$1
  hostname=$(aws ec2 describe-instances --instance-ids "$instanceid" --query Reservations[0].Instances[0].PublicDnsName --output text)
  echo
  echo "Ok.  To log back into the instance, run:"
  echo
  echo "    ssh ec2-user@$hostname"
  echo
  echo "To shut it down later, run:"
  echo
  echo "    aws ec2 terminate-instances --instance-ids $instanceid"
  echo
}
