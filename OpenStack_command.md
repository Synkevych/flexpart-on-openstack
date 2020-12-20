OpenStack is a set of software components that provide common services for cloud infrastructure. OpenStack controls large pools of compute, storage, and networking resources, all managed through APIs or a dashboard.

### A set of commands for working with OpenStack  

- Set environment variables from file for work with OpenStack infrastructures

```bash
. ENV.rc
```

- See the list of available virtual machines

```bash
nova list 2>/dev/null
#  2>/dev/null command that cancels standard output and show only info about running VM
# or
openstack server list
```

- create new key-pair for connect to instate(it is recommended to have a unique key pair for each instance)

```bash
openstack keypair create $KEY_NAME

# and save private key to the file named $KEY_NAME.key in the .ssh/ folder
openstack keypair create $KEY_NAME >> .ssh/"${KEY_NAME}.key"
# change access to the file for use created file
chmod 600 .ssh/"${KEY_NAME}.key" 
```

- Delete keypair

```bash
openstack keypair delete keypair_name

# or for multiply

openstack keypair list -c Name -f value | grep private-key | xargs -n1 openstack keypair delete
```

- Starting a new virtual machine

```bash
openstack server create --flavor 4 \
--image CirrOS  --key-name synkevych_key \
--security-group global_http myNewServer

# or

nova boot --flavor 3 --image 5c4ceaf0-2d65-46a0-b62d-4be163804809 --key-name cloud_key --security-groups d134acb2-e6bc-4c82-a294-9617fdf7bf07 --user-data \
/home/helloworld.sh $VMNAME 2>/dev/null

# --user-date used for passed the script helloworld.sh for execution
```

- show all available cpu/ram/rom on OpenStack

```bash
nova hypervisor-stats
```

- show list of define the compute, memory, and storage capacity of nova computing instances

```bash
nova flavor-list
# or
openstack flavor list
```

- all available images with OS and libraries

```bash
openstack image list
# show images only with Ubuntu
openstack image list | grep -i Ubuntu-14
```

- list of security group

```bash
openstack security group list
# used to configure access when creating an instance
```

- connect to the created instances using key pair

```bash
ssh -i ~/.ssh/KEY_NAME.pem USER@SERVER_IP
# default user for Ubuntu - ubuntu
```

- change instances status to pause or shutdown

```bash
openstack server pause vm_name # or ID
# make active
openstack server unpause vm_name
# shutoff
openstack server stop vm_name
openstack server start vm_name
```

- Delete a virtual machine by Name or ID

```bash
nova delete 3fa580df-0035-4d2c-809a-cdefe66a9d41 2>/dev/null
# or
openstack server delete myNewServer
# or for multiply
openstack server list -c Name -f value | grep roman_vm_ | xargs -n1 openstack server delete
```

### Handling error

- Show hypervisor hostname, it's state and status

```bashсистеми
nova hypervisor-list
# useful if you can't connect to your instance
```
