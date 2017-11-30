#!/bin/sh

groupname=$1

echo -n "Initiate rolling upgrade? [Y/n] "
read upgrade
if [ "$upgrade" = "y" ] || [ "$upgrade" = "Y" ] || [ "$upgrade" = "" ]; then
  currentsize=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$groupname" --query AutoScalingGroups[0].DesiredCapacity)
  currentmax=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$groupname" --query AutoScalingGroups[0].MaxSize)
  scaledsize=$((currentsize * 2))
  if [ $scaledsize -gt $currentmax ]; then
    $(aws autoscaling update-auto-scaling-group --auto-scaling-group-name "$groupname" --max-size $scaledsize --desired-capacity $scaledsize)
  else
    $(aws autoscaling update-auto-scaling-group --auto-scaling-group-name "$groupname" --desired-capacity $scaledsize)
  fi
  totalcount=$scaledsize
  inservicecount=$currentsize
  lastcount=$inservicecount
  echo -n "Increasing cluster size to $scaledsize from $currentsize"
  while [ $inservicecount -lt $scaledsize ]; do
    instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$groupname" --query AutoScalingGroups[0].Instances --output text)
    totalcount=$(cat <<EOF |wc -l 
$instances
EOF
    )
    inservicecount=$(cat <<EOF |grep InService |wc -l
$instances
EOF
    )
    echo -n .
    if [ $inservicecount != $lastcount ] && [ $inservicecount != $scaledsize ]; then
      echo -n $inservicecount
      lastcount=$inservicecount
    fi
    sleep 5
  done
  echo done
  echo -n "Terminating old instances"
  $(aws autoscaling update-auto-scaling-group --auto-scaling-group-name "$groupname" --desired-capacity $currentsize)
  while [ $inservicecount -gt $currentsize ]; do
    instances=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$groupname" --query AutoScalingGroups[0].Instances --output text)
    totalcount=$(cat <<EOF |wc -l 
$instances
EOF
    )
    inservicecount=$(cat <<EOF |grep InService |wc -l
$instances
EOF
    )
    if [ $inservicecount != $lastcount ] && [ $inservicecount != $currentsize ]; then
      echo -n $inservicecount
      lastcount=$inservicecount
    fi
    echo -n .
    sleep 5
  done
  echo done
fi

