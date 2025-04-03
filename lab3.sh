#!/bin/bash

# Check if verbose mode is enabled
verbose=0
if [[ "$1" == "-verbose" ]]; then
    verbose=1
    shift
fi

# Define server IPs
server1="server1-mgmt"
server2="server2-mgmt"

# Copy and run the script on server1
scp configure-host.sh remoteadmin@$server1:/root
ssh remoteadmin@$server1 "/root/configure-host.sh -verbose -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4"

# Copy and run the script on server2
scp configure-host.sh remoteadmin@$server2:/root
ssh remoteadmin@$server2 "/root/configure-host.sh -verbose -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3"

# Update the local /etc/hosts file
./configure-host.sh -hostentry loghost 192.168.16.3
./configure-host.sh -hostentry webhost 192.168.16.4
