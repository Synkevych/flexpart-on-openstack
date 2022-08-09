# OpenStack

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

# grep all machines by 'flexpart' name 
openstack server list | grep flexpart
```

- create new flavor list

`openstack flavor create --public m16.large --id 16 --ram 16384 --disk 40 --vcpus 16`

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

# --user-data used for passed the script helloworld.sh for execution
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

# create new image from running instance (use $nova list to show current images)
nova image-create current-instance-id new-image-name
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

- Take a snapshot of your instance

`openstack server image create --name test_snapshot <instance name or uuid>`

- Download the snapshot as an image

`glance image-download --file snapshot-name.raw image-ID`

- Save an image as a file (to download it later)

`openstack image save --file snapshot-name.raw image-ID`

- Import the snapshot to the new environment

`openstack image create --container-format bare --disk-format qcow2 --file snapshot-name.raw myInstanceSnapshot`

### Handling error

#### Show hypervisor hostname, it's state and status

```bashсистеми
nova hypervisor-list
# useful if you can't connect to your instance
```

#### Change fixed IP address

1. Find your port ID and instance data in these commands:
```
openstack server list
openstack port list | grep YOUR_OLD_INSTANCE_IP
openstack network list
```
2. Stop server
3. Delete IP assigned to your port of instance and make this instance without IP: `openstack port delete 4719c03a-c92c-4958-9521-456b70f6869f`
4. Generate a new random IP 
```
# remove existing IP
openstack server remove fixed ip <server> <ip-address>

# generate a new random IP
openstack server add fixed ip <server> <ip-address>
```

#### Delete port

`openstack port delete <ID>`

#### Generate a new port

```
openstack port create --network private --fixed-ip \
subnet=private_subnet,ip-address=10.10.1.20 server1-port0
```

### Copy file from main server to vm

`scp user_name@host.kyiv.ua:/home/user_name/archive.tar.xz .` - copy file to current path, you should provide host, user name and password;  
`tar -xvf archive.tar.xz` - unzip tar file  

