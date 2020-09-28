#!/bin/bash

# generate random name for VMNAME
VMNAME=vm_`date --utc +%Y%m%d%H%M%S`
TIMER=60

# go to HOME and Passing openstack Variables to Environment Variables(needed to launch an instance)
cd
. WRF-UNG.rc

# try to start a new virtual machine
nova boot --flavor 3 --image 5c4ceaf0-2d65-46a0-b62d-4be163804809 --key-name cloud_key --security-groups d134acb2-e6bc-4c82-a294-9617fdf7bf07 --user-data $home/helloworld.sh $VMNAME 2>/dev/null
   for i in `seq 1 3`; do
      sec=$TIMER
      while [ $sec -ge 0 ]; do
	      echo -ne "$i attempt to start VM: $sec\033[0K\r"
              let "sec=sec-1"
              sleep 1
      done
     
     STATUS=`openstack server list | grep $VMNAME | awk '{ print $6 }'`
     IP=`openstack server list | grep $VMNAME | awk '{ print $8 }'`
     SYSTEM=`openstack server list | grep $VMNAME | awk '{ print $10 $11 }'`
     
     echo "VM status is - $STATUS"
     if [ "x$STATUS" = "xACTIVE" ]; then
       echo "VM $VMNAME is $STATUS, IP address $IP, system $SYSTEM"
       exit
     fi
   done
   openstack server delete `openstack server list | grep $VMNAME | awk '{ print $2 }'`
done
