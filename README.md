# linux_openvfd-build

Builds the kernel module from https://github.com/arthur-liberman/linux_openvfd/
for the kernel and kernel headers in the latest release (whichever that is)
from https://github.com/devmfc/debian-on-amlogic/releases/.

## Overview

This repository provides automated building of the OpenVFD kernel module for Amlogic devices running the debian-on-amlogic kernel. The OpenVFD driver supports various LED display controllers (FD628, FD650, HD44780, etc.) commonly found on Android TV boxes.

## Current Build Target

- **Kernel Version**: 6.18.5-meson64
- **Architecture**: ARM64 (aarch64)
- **Kernel Headers**: linux-headers-6.18.5-meson64_20260113_arm64.deb

## Building Locally

### Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y gcc-aarch64-linux-gnu make wget
```

### Build Instructions

```bash
chmod +x build.sh
./build.sh
```

The built kernel module will be saved to `output/openvfd.ko`.

## GitHub Actions

The repository includes a GitHub Actions workflow that automatically builds the kernel module on every push to main/master branches. The built module is uploaded as an artifact that can be downloaded from the Actions tab.

To manually trigger a build:
1. Go to the Actions tab
2. Select "Build OpenVFD Kernel Module" workflow
3. Click "Run workflow"

## Using the Kernel Module

1. Download the `openvfd.ko` file from the latest build artifacts
2. Copy it to your Amlogic device
3. Load the module:
   ```bash
   sudo insmod openvfd.ko
   ```

For more information about configuring OpenVFD, see:
- https://github.com/arthur-liberman/linux_openvfd/
- https://forum.armbian.com/topic/55312-install-openvfd-for-lcd-display-on-recent-612-kernels-tutorial/ 
