#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 VM_name"; exit 1; fi

VMNAME=$1

rm ".ssh/${VM_NAME}.key"

openstack keypair delete ${VM_NAME}

openstack server delete ${VM_NAME}
