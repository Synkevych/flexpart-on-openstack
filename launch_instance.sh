#!/bin/bash

# create a new key pair for connections to the instance

KEY_NAME="private-key-`date --utc +%Y%m%d%H%M`"
FILE_PATH=.ssh/"${KEY_NAME}.key"
openstack keypair create $KEY_NAME >> $FILE_PATH
chmod 600 .ssh/"${KEY_NAME}.key"

# create an instane

VMNAME="${USER}"_vm_`date --utc +%Y%m%d%H%M%S`
TIMER=60

cd 
. WRF-UNG.rc

while true; do
   nova boot --flavor d56ee93c-4034-4399-9a82-7d64a0488878 --image 5c4ceaf0-2d65-46a0-b62d-4be163804809 --key-name $KEY_NAME --security-groups d134acb2-e6bc-4c82-a294-9617fdf7bf07 $VMNAME 2>/dev/null
   for i in `seq 1 3`; do
      sec=$TIMER
      while [ $sec -ge 0 ]; do
	      echo -ne "$i attempt to start VM: $sec\033[0K\r"
              let "sec=sec-1"
              sleep 1
      done

     STATUS=`openstack server list | grep $VMNAME | awk '{ print $6 }'`
     IP=`openstack server list | grep $VMNAME | awk '{ split($8, v, "="); print v[2]}'`
     SYSTEM=`openstack server list | grep $VMNAME | awk '{ print $10 $11 }'`
    
     printf "\nVM $VMNAME has the status - $STATUS\n"
     if [ "x$STATUS" = "xACTIVE" ]; then
       printf "VM $VMNAME is $STATUS, IP address $IP, system $SYSTEM\n"
       printf "To connect use: ssh -i $FILE_PATH ubuntu@$IP\n"
       exit
     fi
   done
   openstack server delete `openstack server list | grep $VMNAME | awk '{ print $2 }'`
done
