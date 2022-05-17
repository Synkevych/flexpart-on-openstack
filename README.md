<h1 align="center"> flexpart-on-openstack </h1>
<p align="center">
This is a project to create many (a dozen or more) virtual machines(instance) in cloud web services based on OpenStack, to calculate a flexpart model for predicting the spread of air pollution.

The main commands for working with OpenStack are described in the [OpenStack Command](doc/OpenStack_command.md) file. Installation instructions for flexpart and its component - [Flexpart Installing](doc/flexpart_Installing.md).
</p>

### Features

- Create a new instance in OpenStack with certain hardware characteristics and OS
- Transfer setup_flexpart.sh script to this machine
- Setup flexpart and they all dependencies
- Download the weather forecast data to the instance according to the task
- Run the flexpart model and wait for the result
- After the completion of the calculation, transfer the result to the remote server
- Remove the virtual machine from OpenStack and free up resources for other tasks

### Scripts

- Script to run a single instance in openstack: [launch_instance](launch_instance.sh)
- Script to run multiple instances(100): [run_multiple_instances](run_multiple_instances.sh)
- Automatic configuration flexpart: [setup_flexpart](setup_flexpart.sh)
- Download grib files: [downloads_grib](downloads_grib.sh)

### Improving performance and speed of scripts

- All required scripts are located on [ukrainian server](http://env.com.ua/~sunkevu4/flexpart/all_libs.tar.gz) or [github mirror](https://github.dev/Synkevych/flexpart-on-openstack/libs)
- Create as OS image with flexpart properly installed
- Upload the forecast to a separate location with the ability to access from all instances

### References

- Flexpart cite: <http://flexpart.eu/>
- Weather forecast site: <https://www.ncei.noaa.gov/>
