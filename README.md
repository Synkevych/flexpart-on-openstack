# openstack

This is a project to create many (a dozen or more) virtual machines(instance) in cloud web services based on OpenStack, to calculate a flexpart model for predicting the spread of air pollution.

The main commands for working with OpenStack are described in the file: [OpenStack_command](OpenStack_command.md)

Installation instructions for flexpart  and its components: [flexpart_Installing](flexpart_Installing.md)

### Main tasks:

1. Create a new instance in OpenStack with certain hardware characteristics and OS
2. Transfer the script to this machine
3. The script should download the weather forecast data to the instance
4. After loading the data, run the flexpart model and wait for the result
5. After the completion of the calculation, we transfer the result to the remote server
6. Remove the virtual machine from OpenStack and free up resources for other tasks

Script to run one instance: [launch_instance](launch_instance.sh)

Script to run 100 instances: [run_multiple_instances](run_multiple_instances.sh)
