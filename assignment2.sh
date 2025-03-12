#!/bin/bash

# Check if the necessary network configuration is present
echo "Checking network configuration for 192.168.16.21..."
NETWORK_CONFIG="/etc/netplan/01-netcfg.yaml"
IP_ADDRESS="192.168.16.21/24"

# Update netplan file if needed
if ! grep -q "$IP_ADDRESS" "$NETWORK_CONFIG"; then
    echo "Updating network configuration..."
    # Modify the netplan configuration here
    # (This is just an example, adjust based on your system's actual netplan file)
    echo -e "network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    eth0:\n      dhcp4: no\n      addresses:\n        - $IP_ADDRESS" > "$NETWORK_CONFIG"
    netplan apply
else
    echo "Network already configured correctly."
fi

# Check /etc/hosts and add the correct IP for server1
echo "Updating /etc/hosts file..."
HOSTS_FILE="/etc/hosts"
if ! grep -q "192.168.16.21" "$HOSTS_FILE"; then
    echo "Adding 192.168.16.21 for server1 in /etc/hosts..."
    echo "192.168.16.21 server1" >> "$HOSTS_FILE"
else
    echo "/etc/hosts already contains correct entry."
fi

# Ensure apache2 and squid are installed and running
echo "Ensuring apache2 and squid are installed and running..."
if ! dpkg -l | grep -q apache2; then
    echo "Installing apache2..."
    apt-get update && apt-get install -y apache2
fi
if ! dpkg -l | grep -q squid; then
    echo "Installing squid..."
    apt-get install -y squid
fi
systemctl enable apache2 squid
systemctl start apache2 squid

# Create users and set up SSH keys
USERS=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"
for user in "${USERS[@]}"; do
    # Check if user exists, if not, create user
    if id "$user" &>/dev/null; then
        echo "User $user already exists."
    else
        echo "Creating user $user..."
        useradd -m -s /bin/bash "$user"
    fi

    # Add SSH keys
    mkdir -p "/home/$user/.ssh"
    echo "$SSH_KEY" >> "/home/$user/.ssh/authorized_keys"
    chown -R "$user":"$user" "/home/$user/.ssh"
    chmod 700 "/home/$user/.ssh"
    chmod 600 "/home/$user/.ssh/authorized_keys"

    # Add 'dennis' to sudo group
    if [ "$user" == "dennis" ]; then
        usermod -aG sudo "$user"
    fi
done

echo "Script completed successfully!"
