# linux_openvfd-build

Builds the kernel module and OpenVFDService from https://github.com/arthur-liberman/linux_openvfd/
for the kernel and kernel headers in the latest release (whichever that is)
from https://github.com/devmfc/debian-on-amlogic/releases/.

## Overview

This repository provides automated building of the OpenVFD kernel module and service for Amlogic devices running the debian-on-amlogic kernel. The OpenVFD driver supports various LED display controllers (FD628, FD650, HD44780, etc.) commonly found on Android TV boxes.

## Current Build Target

- **Kernel Version**: 6.18.5-meson64
- **Architecture**: ARM64 (aarch64)
- **Kernel Headers**: linux-headers-6.18.5-meson64_20260113_arm64.deb

## Quick Installation (Recommended)

The easiest way to install OpenVFD is to download a pre-built release:

1. **Download the latest release** from the [Releases page](../../releases)
2. **Extract the zip file** on your device
3. **Run the installation script**:
   ```bash
   cd openvfd-release
   sudo ./install.sh
   ```

The installation script will automatically:
- Install the kernel module
- Install the OpenVFDService binary
- Download and configure TX92 VFD settings (you can modify this for your device)
- Set up and enable a systemd service

### Post-Installation

After installation, you can manage the service with:

```bash
# Check service status
systemctl status openvfd.service

# View live logs
journalctl -u openvfd.service -f

# Restart the service
systemctl restart openvfd.service

# Edit configuration
nano /storage/.config/vfd.conf
# or
nano /etc/openvfd/vfd.conf
```

## Building Locally

### Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y gcc-aarch64-linux-gnu make wget curl zip
```

### Build Instructions

```bash
# Build the kernel module and OpenVFDService
chmod +x build.sh
./build.sh

# Create a release package
chmod +x package.sh
./package.sh
```

The built files will be in:
- `output/openvfd.ko` - Kernel module
- `output/OpenVFDService` - Service binary
- `openvfd-*.zip` - Complete release package

## GitHub Actions

The repository includes a GitHub Actions workflow that automatically builds the kernel module and service on every push. Release packages are uploaded as artifacts.

To create a new release:
1. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. The workflow will automatically create a GitHub Release with the packaged zip file

## Configuration

The default installation uses the TX92 configuration. If you have a different device, you'll need to find the appropriate configuration from:
- https://github.com/arthur-liberman/vfd-configurations

After installation, edit the configuration file and restart the service:
```bash
nano /storage/.config/vfd.conf  # or /etc/openvfd/vfd.conf
systemctl restart openvfd.service
```

## Package Contents

Each release package includes:
- `openvfd.ko` - Linux kernel module for VFD/LED displays
- `OpenVFDService` - User-space service (statically linked for maximum compatibility)
- `install.sh` - Automated installation script
- `README.txt` - Package documentation
- `VERSION.txt` - Build information

## Troubleshooting

If the display doesn't work after installation:

1. **Check if the module is loaded**:
   ```bash
   lsmod | grep openvfd
   ```

2. **Check service status**:
   ```bash
   systemctl status openvfd.service
   journalctl -u openvfd.service -n 50
   ```

3. **Try loading the module manually**:
   ```bash
   sudo modprobe openvfd
   ```

4. **Verify your device configuration** - you may need a different config file from:
   https://github.com/arthur-liberman/vfd-configurations

## Additional Resources

For more information about OpenVFD, see:
- https://github.com/arthur-liberman/linux_openvfd/
- https://forum.armbian.com/topic/55312-install-openvfd-for-lcd-display-on-recent-612-kernels-tutorial/ 
