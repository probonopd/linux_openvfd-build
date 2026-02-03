#!/bin/bash
# Package script for OpenVFD release
set -e

echo "Creating OpenVFD release package..."

# Configuration
PACKAGE_NAME="openvfd-release"
OUTPUT_DIR="$(pwd)/output"
PACKAGE_DIR="$(pwd)/$PACKAGE_NAME"

# Check if output directory exists
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Error: output directory not found. Please run build.sh first."
    exit 1
fi

# Check if required files exist
if [ ! -f "$OUTPUT_DIR/openvfd.ko" ]; then
    echo "Error: openvfd.ko not found. Please run build.sh first."
    exit 1
fi

if [ ! -f "$OUTPUT_DIR/OpenVFDService" ]; then
    echo "Error: OpenVFDService not found. Please run build.sh first."
    exit 1
fi

# Create package directory
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# Copy files to package directory
echo "Copying files..."
cp "$OUTPUT_DIR/openvfd.ko" "$PACKAGE_DIR/"
cp "$OUTPUT_DIR/OpenVFDService" "$PACKAGE_DIR/"
cp install.sh "$PACKAGE_DIR/"
chmod +x "$PACKAGE_DIR/install.sh"

# Create README for the package
cat > "$PACKAGE_DIR/README.txt" << 'EOF'
OpenVFD Kernel Module and Service Package
==========================================

This package contains:
- openvfd.ko: Linux kernel module for VFD/LED displays
- OpenVFDService: User-space service for controlling the display
- install.sh: Installation script

Built for: Linux kernel 6.18.5-meson64 (ARM64/aarch64)

Quick Installation
------------------
1. Copy this entire folder to your device (e.g., via SSH or USB)
2. Run the installation script as root:
   sudo ./install.sh

The installation script will:
- Install the kernel module to /lib/modules/<kernel-version>/kernel/drivers/misc/
- Install OpenVFDService to /usr/local/bin/
- Download and configure TX92 VFD configuration
- Create and enable a systemd service
- Start the service automatically

Post-Installation
-----------------
After installation, you can:
- Check service status: systemctl status openvfd.service
- View logs: journalctl -u openvfd.service -f
- Restart service: systemctl restart openvfd.service
- Edit configuration: /storage/.config/vfd.conf or /etc/openvfd/vfd.conf

Configuration
-------------
The default configuration is for TX92 devices. If you have a different device,
you may need to adjust the configuration file. See:
https://github.com/arthur-liberman/vfd-configurations

For more information, visit:
- https://github.com/arthur-liberman/linux_openvfd
- https://github.com/probonopd/linux_openvfd-build
EOF

# Create version file
KERNEL_VERSION="6.18.5-meson64"
BUILD_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
cat > "$PACKAGE_DIR/VERSION.txt" << EOF
OpenVFD Package Version Information
====================================
Build Date: $BUILD_DATE
Target Kernel: $KERNEL_VERSION
Architecture: ARM64 (aarch64)
Package Contents:
  - OpenVFD kernel module (openvfd.ko)
  - OpenVFDService binary (statically linked)
  - Installation script (install.sh)
EOF

# Create the zip file
ZIP_NAME="openvfd-${KERNEL_VERSION}-$(date -u +%Y%m%d).zip"
echo "Creating zip file: $ZIP_NAME"
cd "$(dirname "$PACKAGE_DIR")"
zip -r "$ZIP_NAME" "$(basename "$PACKAGE_DIR")"

echo ""
echo "Package created successfully!"
echo "Package location: $(pwd)/$ZIP_NAME"
echo ""
echo "Contents:"
unzip -l "$ZIP_NAME"
