#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 VM_name"; exit 1; fi

set -e

. ENV # load openstack environment variables

VM_NAME=$1
STATUS=`openstack server list | grep $VM_NAME | awk '{ print $6 }'`
TIME=$(date "+%d.%m.%y-%H:%M:%S")

if test -z "$STATUS"; then
        echo "$VM_NAME VM not found, canceling"
        echo -e "$TIME $VM_NAME VM not found, canceling\n" >> vm_launching.log
        exit
fi

echo "VM $VM_NAME found, starting removing"

rm ".ssh/${VM_NAME}.key"
echo "$TIME SSH key for $VM_NAME deleted" >> vm_launching.log

openstack keypair delete ${VM_NAME}
echo "$TIME Openstak keypair for $VM_NAME deleted" >> vm_launching.log

openstack server delete ${VM_NAME}
echo -e "$TIME Openstack server $VM_NAME deleted\n" >> vm_launching.log

echo "VM $VM_NAME and it keys successfully removed"
