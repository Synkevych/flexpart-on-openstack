# openstack

This is a project to create many (a dozen or more) virtual machines(instance) in cloud web services based on OpenStack, to calculate a **flexpart** model for predicting the spread of air pollution.

The main commands for working with OpenStack are described in the file: [OpenStack_command](doc/OpenStack_command.md)

Installation instructions for flexpart  and its components: [flexpart_Installing](doc/flexpart_Installing.md)

### Main tasks

- Create a new instance in OpenStack with certain hardware characteristics and OS
- Transfer the script to this machine
- The script should download the weather forecast data to the instance
- After loading the data, run the flexpart model and wait for the result
- After the completion of the calculation, we transfer the result to the remote server
- Remove the virtual machine from OpenStack and free up resources for other tasks

Script to run one instance: [launch_instance](launch_instance.sh)

Script to run 100 instances: [run_multiple_instances](run_multiple_instances.sh)

### Improving performance and speed of scripts

- All required scripts are located on [ukrainian server](www.env.kiew.ua)
- Create as OS image with flexpart properly installed
- Upload the forecast to a separate location with the ability to access from all instances

### References

Flexpart cite: <http://flexpart.eu/>  
Weather forecast site: <https://www.ncei.noaa.gov/>  
