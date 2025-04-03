#!/bin/bash

verbose=0

# Parse command-line arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -verbose)
            verbose=1
            shift
            ;;
        -name)
            desiredName="$2"
            shift 2
            ;;
        -ip)
            desiredIP="$2"
            shift 2
            ;;
        -hostentry)
            hostName="$2"
            hostIP="$3"
            shift 3
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Function to log changes
log_change() {
    if [ $verbose -eq 1 ]; then
        echo "$1"
    fi
    logger "$1"
}

# Handle -name (hostname) option
if [ ! -z "$desiredName" ]; then
    currentName=$(cat /etc/hostname)
    if [ "$currentName" != "$desiredName" ]; then
        echo "$desiredName" > /etc/hostname
        hostname "$desiredName"
        log_change "Hostname changed to $desiredName"
    elif [ $verbose -eq 1 ]; then
        echo "Hostname is already $desiredName"
    fi
fi

# Handle -ip (IP address) option
if [ ! -z "$desiredIP" ]; then
    currentIP=$(hostname -I | awk '{print $1}')
    if [ "$currentIP" != "$desiredIP" ]; then
        # Example for netplan config (assuming netplan is in use)
        sed -i "s/$currentIP/$desiredIP/" /etc/netplan/*.yaml
        netplan apply
        log_change "IP address changed to $desiredIP"
    elif [ $verbose -eq 1 ]; then
        echo "$desiredIPAddress $desiredName" | sudo tee -a /etc/hosts > /dev/null
    fi
fi

# Handle -hostentry (hosts file entry) option
if [ ! -z "$hostName" ] && [ ! -z "$hostIP" ]; then
    if ! grep -q "$hostIP" /etc/hosts; then
        echo "$hostIP $hostName" >> /etc/hosts
        log_change "Added entry to /etc/hosts: $hostIP $hostName"
    elif [ $verbose -eq 1 ]; then
        echo "Entry $hostName $hostIP already exists in /etc/hosts"
    fi
fi
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi
