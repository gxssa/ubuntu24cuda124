#!/bin/bash

# Ubuntu 24.04 Setup Script
# Installs: Build essentials, CUDA 12.4, Node.js 18, PM2, w.ai
# Quick setup for w.ai on cloud GPU pods

set -e  # Exit on any error

echo "========================================="
echo "Ubuntu 24.04 Setup Script Starting..."
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

print_status "Starting system update and essential packages installation..."

# Set timezone and install tzdata non-interactively
print_status "Setting up timezone and essential packages..."
export DEBIAN_FRONTEND=noninteractive
export TZ=UTC

# Update package lists first
apt update -y

# Install tzdata and set timezone
apt install -y tzdata
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Install essential build tools and dependencies
print_status "Installing essential build tools and dependencies..."
apt install -y wget build-essential curl
apt install -y libxml2-dev libxslt1-dev zlib1g-dev libffi-dev libssl-dev

# Additional update after initial installations
print_status "Running additional system update..."
apt update -y

print_status "========================================="
print_status "Starting CUDA 12.4 installation..."
print_status "========================================="

# Download CUDA 12.4 installer
print_status "Downloading CUDA 12.4 installer..."
if [ ! -f "cuda_12.4.0_550.54.14_linux.run" ]; then
    wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda_12.4.0_550.54.14_linux.run
else
    print_warning "CUDA installer already exists, skipping download..."
fi

# Make installer executable and run it
print_status "Installing CUDA 12.4 toolkit..."
chmod +x cuda_12.4.0_550.54.14_linux.run
sh cuda_12.4.0_550.54.14_linux.run --toolkit --silent --override

echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

print_status "CUDA paths added and loaded successfully"

print_status "CUDA 12.4 installation completed!"

print_status "========================================="
print_status "Starting Node.js 18 and PM2 installation..."
print_status "========================================="

# Install Node.js 18
print_status "Adding Node.js 18 repository..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

print_status "Installing Node.js 18..."
apt install -y nodejs

# Verify Node.js installation
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_status "Node.js installed: $NODE_VERSION"
print_status "NPM installed: $NPM_VERSION"

# Install PM2 globally
print_status "Installing PM2 globally..."
npm install -g pm2

# Verify PM2 installation
PM2_VERSION=$(pm2 --version)
print_status "PM2 installed: $PM2_VERSION"

print_status "========================================="
print_status "Installation Summary"
print_status "========================================="

# Display installation summary
print_status "✅ System packages updated"
print_status "✅ Build essentials installed"
print_status "✅ Development libraries installed"
print_status "✅ CUDA 12.4 toolkit installed"
print_status "✅ Node.js $NODE_VERSION installed"
print_status "✅ PM2 $PM2_VERSION installed"

print_status "Environment variables loaded and active!"

# Optional: Test CUDA installation
if command -v nvcc &> /dev/null; then
    CUDA_VERSION=$(nvcc --version | grep "release" | awk '{print $6}' | cut -c2-)
    print_status "✅ CUDA compiler (nvcc) available - Version: $CUDA_VERSION"
else
    print_warning "CUDA compiler test failed, but installation should be complete"
fi

# Install w.ai
print_status "Installing w.ai..."
curl -fsSL https://app.w.ai/install.sh | bash

print_status "========================================="
print_status "Setup completed successfully!"
print_status "Your Ubuntu 24.04 system is now ready with:"
print_status "- Build tools and development libraries"
print_status "- CUDA 12.4 toolkit"
print_status "- Node.js 18 and NPM"
print_status "- PM2 process manager"
print_status "- w.ai installed"
print_status "========================================="

# Clean up downloaded installer automatically
print_status "Cleaning up CUDA installer file..."
rm -f cuda_12.4.0_550.54.14_linux.run
print_status "CUDA installer file removed."

print_status "Script execution completed!"
