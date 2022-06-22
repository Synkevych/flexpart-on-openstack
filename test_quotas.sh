#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 flavor_name"; exit 1; fi

set -e

. ENV # load openstack environment variables

flavor_cores=`openstack flavor list | grep $1 | awk '{ print $12 }'`

limits=`nova limits 2>/dev/null | grep 'Cores\|Instances'`
all_cores=`echo $limits | awk '{ print $6 }'`
used_cores=`echo $limits | awk '{ print $4 }'`

all_instances=`echo $limits | awk '{ print $13 }'`
used_instances=`echo $limits | awk '{ print $11 }'`

if (( $used_cores + $flavor_cores >= $all_cores )); then
        echo "The core limit was reached! Your need to fire $(expr $all_cores - $used_cores + $flavor_cores ) cores. Canceling ...";
	exit 0
fi

if (( $used_instances + 1 >= $all_instances )); then
	echo "The instance limit was reached. Canceling ...";
	exit 0
fi

echo "Everything is fine, the limit is not reached"
