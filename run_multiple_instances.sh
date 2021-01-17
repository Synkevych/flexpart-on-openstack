#!/bin/bash

# launch 100 virtual machines

for i in `seq 1 50`; do
  echo "$i start launching 2 instances" >> vm_launching.log
  for i in `seq 1 2`; do
    ./launch_instance.sh
  done

  # wait a minute after starting, the approximate running time of the calculation model
  sleep 60

  # remove instances
  openstack server list -c Name -f value | grep roman_vm_ | xargs -n1 openstack server delete
  echo "2 instances deleted" >> vm_launching.log
  # remove keypair (private and public)
  openstack keypair list -c Name -f value | grep private-key | xargs -n1 openstack keypair delete
  rm .ssh/private-key-*
  echo "2 key pairs deleted" >> vm_launching.log
done
