#!/bin/bash

set -e

HASH=`date --utc +%Y%m%d%H%M`; FLAVOR="m1.large"; VMNAME="flexpart_${FLAVOR/./_}_${HASH}"
TIME=$(date "+%d.%m.%Y-%H:%M:%S"); TIMER=20; w=.ssh/"${VMNAME}.key"

# test is there resources for a new instance
source test_quotas.sh $FLAVOR

. ENV # source OpenStack environment variable values

KEY_PATH=.ssh/"${VMNAME}.key"
openstack keypair create $VMNAME >> $KEY_PATH; chmod 600 .ssh/"${VMNAME}.key"

TIMER=60

nova boot --flavor $FLAVOR\
        --image d4504b10-f0c7-4460-8798-4706da6d5230\
        --key-name $VMNAME\
        --security-groups d134acb2-e6bc-4c82-a294-9617fdf7bf07\
        $VMNAME 2>/dev/null
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
  
  if [ "x$STATUS" = "xACTIVE" ]; then
    printf "VM $VMNAME is $STATUS, IP address $IP, system $SYSTEM\n"
    echo "VM $VMNAME is $STATUS, IP address $IP, system $SYSTEM" >> vm_launching.log
    printf "To connect use: ssh -i $KEY_PATH ubuntu@$IP\n"
    echo -e "To connect use: ssh -i $KEY_PATH ubuntu@$IP\n" >> vm_launching.log
    exit
  fi
done

if test -z "$STATUS"; then
        echo "Launching $VMNAME failed"
        echo -e "$TIME Launching VM $VMNAME failed\n" >> vm_launching.log
        rm ".ssh/${VMNAME}.key"
        openstack keypair delete ${VMNAME}`
        exit
fi

printf "Launching $VMNAME failed"
echo -e "Launching $VMNAME failed with status: $STATUS\n" >> vm_launching.log
rm ".ssh/${VMNAME}.key"
openstack keypair delete ${VMNAME}`
openstack server delete `openstack server list | grep $VMNAME | awk '{ print $2 }'`
