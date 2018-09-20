#!/bin/bash
#AWS CREATE IMAGE and CLEAN old images with snapshot

DATE=$(date +%Y-%m-%d)
PREVIOUSDATE=$(date +%Y-%m-%d -d "yesterday")
AMI_NAME="DTR-$DATE"
PREVIOUSAMIVALUE="DTR-$PREVIOUSDATE"
AMI_DESCRIPTION="DTR-$DATE"

# Funtion for standardised Script logging
f_log()
{
  echo  "`date` - $1"
}


f_log "Backing up  DTR AMI"

new_ami_id=`aws ec2 create-image --instance-id i-XXXXXXXXXXXXXX --name "$AMI_NAME" --description "$AMI_DESCRIPTION" --no-reboot`

f_log "${new_ami_id}"

tag=`aws ec2 create-tags --resources ${new_ami_id} --tags Key=Name,Value=${AMI_NAME}`

if [ $? -eq 0 ]; then
        f_log "DTR AMI request complete!"
else
        f_log "no tag create"
fi

#####
f_log "Remove previous AMI's and SNAPSHOTs "
#####

old_ami_id=`aws ec2 describe-images --filters Name=tag:Name,Values=${PREVIOUSAMIVALUE} | head -1 |awk '{print $6}'`

 if [ -z "${old_ami_id}" ]; then
        f_log " NO ${PREVIOUSAMIVALUE} found, please check console"
        exit 0
else f_log "${old_ami_id} found"
fi
#Find snapshots associated with AMI.

`aws ec2 describe-images --image-ids ${old_ami_id} | grep snap | awk ' { print $4 }' > /tmp/snap.txt`

f_log "${old_ami_id} deregistering in progress "

f_log "Following are the snapshots associated with it : `cat /tmp/snap.txt` "

f_log "Starting the Deregister of AMI... \n"

#Deregistering the AMI
`aws ec2 deregister-image --image-id ${old_ami_id}`

f_log "Deleting the associated snapshots...."

#Deleting snapshots attached to AMI
for i in `cat /tmp/snap.txt`;do echo "deleting $i " ; aws ec2 delete-snapshot --snapshot-id $i ; done
f_log "${i} deleted"
