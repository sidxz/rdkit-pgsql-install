#!/bin/bash

# Function to display a progress bar
show_progress() {
    local duration=$1
    local interval=0.1
    local steps=$((duration / interval))
    echo -n "["
    for ((i=0; i<steps; i++)); do
        sleep $interval
        echo -n "="
    done
    echo "]"
}

echo "Starting Docker installation script..."

# Step 1: Update package index
echo "Step 1: Updating package index..."
sudo apt-get update > /dev/null 2>&1
show_progress 3
echo "Package index updated."

# Step 2: Install required packages
echo "Step 2: Installing ca-certificates and curl..."
sudo apt-get install -y ca-certificates curl > /dev/null 2>&1
show_progress 2
echo "ca-certificates and curl installed."

# Step 3: Create keyrings directory
echo "Step 3: Creating keyrings directory..."
sudo install -m 0755 -d /etc/apt/keyrings
show_progress 1
echo "Keyrings directory created."

# Step 4: Add Docker's official GPG key
echo "Step 4: Adding Docker's official GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
show_progress 2
echo "Docker GPG key added."

# Step 5: Add Docker repository to Apt sources
echo "Step 5: Adding Docker repository to Apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update > /dev/null 2>&1
show_progress 3
echo "Docker repository added and package index updated."

# Step 6: Install Docker packages
echo "Step 6: Installing Docker packages..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
show_progress 5
echo "Docker packages installed."

echo "Docker installation script completed successfully."
