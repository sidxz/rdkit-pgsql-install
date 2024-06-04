#!/bin/bash

# Check if UUID is provided as a command-line parameter
if [ -z "$1" ]; then
  echo "Usage: $0 <uuid>"
  echo "Example: $0 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  exit 1
fi

# UUID of the disk to be mounted
UUID="$1"

# Mount point
MOUNT_POINT="/data"

# Create the mount point
echo "Creating mount point $MOUNT_POINT..."
sudo mkdir -p $MOUNT_POINT
sudo mkdir -p $MOUNT_POINT/moldb

# Mount the disk
echo "Mounting disk with UUID=$UUID to $MOUNT_POINT..."
sudo mount -t ext4 -U $UUID $MOUNT_POINT

# Backup fstab
echo "Backing up /etc/fstab to /etc/fstab.bak..."
sudo cp /etc/fstab /etc/fstab.bak

# Add the disk to /etc/fstab
echo "Updating /etc/fstab with UUID=$UUID..."
echo "UUID=$UUID $MOUNT_POINT ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Verify the mount
echo "Verifying the mount..."
df -h | grep $MOUNT_POINT

echo "Disk with UUID $UUID mounted at $MOUNT_POINT, and updated in /etc/fstab successfully."
