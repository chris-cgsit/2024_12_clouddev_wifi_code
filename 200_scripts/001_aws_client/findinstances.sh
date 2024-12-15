#!/bin/bash

rvar=${1:-all}

if [[ "${rvar}" == "all" ]] ;
then
 
  printf "find all your regions:\n"

  aws ec2 describe-regions --output text | cut -f2,4

  printf '\n\n instances:' 
  for region in `aws ec2 describe-regions --output text | cut -f4`
  do 
    echo -e "\nListing Instances in region:'$region'..."
    aws ec2 describe-instances --region $region | jq '.Reservations[] | ( .Instances[] | {state: .State.Name, name: .KeyName, type: .InstanceType, key: .KeyName})'
  done

else

  aws ec2 describe-instances --region $rvar | jq '.Reservations[] | ( .Instances[] | {state: .State.Name, name: .KeyName, type: .InstanceType, key: .KeyName})'

fi


