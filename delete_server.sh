#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 VM NAME"; exit 1; fi

VMNAME=$1

rm ".ssh/${VMNAME}.key"

openstack keypair delete ${VMNAME}

openstack server delete ${VMNAME}
