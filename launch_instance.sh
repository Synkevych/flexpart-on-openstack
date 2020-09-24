#!/bin/bash

# Checking the number of arguments.
if [ $# -ne 1 ]; then echo "Usage: $0 VM_name"; exit 1; fi

# Assigning the first passed parameter to a constant VMNAME
VMNAME=$1

# go to HOME and Passing openstack Variables to Environment Variables(needed to launch an instance)
cd
. WRF-UNG.rc

# try to start a new virtual machine
while true; do
   nova boot --flavor=m1.medium --block-device source=image,id=d9657d95-4800-485b-b082-3e74efe17e9f,dest=volume,size=4,device=/dev/vda,bus=virtio,shutdown=remove,bootindex=0 --key-name cloud_key --security-group "WRF group" $VMNAME 2>/dev/null
   for i in `seq 1 3`; do
     sleep 60
     STATUS=`openstack server list | grep $VMNAME | awk '{ print $6 }'`
     if [ "x$STATUS" = "xACTIVE" ]; then
       echo "STATUS is ACTIVE"
       exit
     fi
   done
   openstack server delete `openstack server list | grep $VMNAME | awk
'{ print $2 }'`
done
