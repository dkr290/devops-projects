#!/bin/bash
# Update system
apt-get update -y
apt-get upgrade -y

# Install NVIDIA drivers (single command)
sudo ubuntu-drivers install --gpgpu
sudo ubuntu-drivers install --gpgpu nvidia:535-server
apt-get install -y nvidia-driver-535

# Verify installation immediately
if nvidia-smi &> /dev/null; then
    echo "SUCCESS: NVIDIA drivers installed correctly"
    nvidia-smi
else
    echo "Installing drivers from Ubuntu repositories..."
    apt-get install -y ubuntu-drivers-common
    ubuntu-drivers autoinstall
    reboot
fi

