#!/bin/bash
export AWS_CONFIG_FILE='AWS_CONFIG'

instance_id=$1

aws --profile nonprodeast  ec2 describe-volumes --region us-east-1 --filters Name=attachment.instance-id,Values=${instance_id} | jq .Volumes[1].Attachments[0].VolumeId | sed 's/"//g'

#aws --profile nonprodeast ec2 detach-volume --volume-id ${vol}

#aws --profile nonprodeast ec2 delete-volume --volume-id ${vol} 

#aws --profile nonprodeast ec2 modify-instance-attribute --instance-id ${instance_id} --disable-api-termination  "{\"Value\": false}"

#aws --profile nonprodeast ec2 terminate-instances --instance-ids ${instance_id}