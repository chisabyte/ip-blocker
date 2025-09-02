#!/bin/bash

# IP Blocker Script using UFW (Uncomplicated Firewall)
# Author: Daniel Chisasura
# This script reads a list of IP addresses from a file and adds 'deny' rules for each.

# --- CONFIGURATION ---
IP_LIST_FILE="malicious_ips.txt" # File containing IPs to block, one per line.

# --- SCRIPT LOGIC ---

# Root check: Firewall rules require root privileges to be modified.
# This ensures the script doesn't fail due to permission errors.
if [[ $EUID -ne 0 ]]; then
   echo "🚫 This script must be run as root (or with sudo)."
   exit 1
fi

# File check: Ensure the IP list file exists before trying to read it.
if [ ! -f "$IP_LIST_FILE" ]; then
    echo "Error: IP list file not found at $IP_LIST_FILE"
    exit 1
fi

echo "🔥 Starting IP blocking process..."
echo "Reading IPs from: $IP_LIST_FILE"
echo "-------------------------------------------------"

# Loop through each line (IP address) in the specified file.
while IFS= read -r ip_address; do
    # Ignore empty lines and lines that start with a '#' (comments).
    if [[ -n "$ip_address" && ! "$ip_address" =~ ^\s*# ]]; then
        echo "Blocking IP: $ip_address"
        # Use ufw to add a rule to deny all incoming traffic from this IP address.
        ufw deny from "$ip_address" to any
    fi
done < "$IP_LIST_FILE"

echo "-------------------------------------------------"
echo "✅ IP blocking script finished."

# Reload the firewall to apply the new rules immediately.
ufw reload
echo "UFW rules have been reloaded."