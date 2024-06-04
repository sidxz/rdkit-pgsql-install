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

# Create the mount point if it does not exist
if [ ! -d "$MOUNT_POINT" ]; then
  echo "Creating mount point $MOUNT_POINT..."
  sudo mkdir -p $MOUNT_POINT
else
  echo "Mount point $MOUNT_POINT already exists."
fi

# Check if the disk is already mounted
if mount | grep "on $MOUNT_POINT type"; then
  echo "Disk with UUID=$UUID is already mounted at $MOUNT_POINT."
else
  # Check if UUID exists
  if ! sudo blkid -U $UUID &> /dev/null; then
    echo "UUID=$UUID does not exist on this system."
    exit 1
  fi

  # Mount the disk
  echo "Mounting disk with UUID=$UUID to $MOUNT_POINT..."
  sudo mount -t ext4 -U $UUID $MOUNT_POINT
  if [ $? -ne 0 ]; then
    echo "Failed to mount disk with UUID=$UUID."
    exit 1
  fi
fi

# Backup fstab
echo "Backing up /etc/fstab to /etc/fstab.bak..."
sudo cp /etc/fstab /etc/fstab.bak

# Check if the disk is already in fstab
if grep -q "UUID=$UUID $MOUNT_POINT" /etc/fstab; then
  echo "UUID=$UUID is already in /etc/fstab."
else
  # Add the disk to /etc/fstab
  echo "Updating /etc/fstab with UUID=$UUID..."
  echo "UUID=$UUID $MOUNT_POINT ext4 defaults 0 2" | sudo tee -a /etc/fstab
fi

# Verify the mount
echo "Verifying the mount..."
df -h | grep $MOUNT_POINT

# Create moldb directory if it does not exist
MOLD_DIR="$MOUNT_POINT/moldb"
if [ ! -d "$MOLD_DIR" ]; then
  echo "Creating moldb directory at $MOLD_DIR..."
  sudo mkdir -p $MOLD_DIR
else
  echo "Directory $MOLD_DIR already exists."
fi

echo "Disk with UUID $UUID mounted at $MOUNT_POINT, and updated in /etc/fstab successfully, if not already done."
