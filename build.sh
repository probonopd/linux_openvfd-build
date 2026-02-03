#!/bin/bash
set -e

echo "Building openvfd kernel module and OpenVFDService for debian-on-amlogic kernel 6.18.5-meson64"

# Configuration
KERNEL_VERSION="6.18.5-meson64"
KERNEL_HEADERS_URL="https://github.com/devmfc/debian-on-amlogic/releases/download/v6.18.5/linux-headers-6.18.5-meson64_20260113_arm64.deb"
OPENVFD_REPO="https://github.com/arthur-liberman/linux_openvfd.git"

# Create build directory
BUILD_DIR="$(pwd)/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download kernel headers
echo "Downloading kernel headers..."
if ! wget -q "$KERNEL_HEADERS_URL" -O linux-headers.deb; then
    echo "Error: Failed to download kernel headers"
    exit 1
fi

# Extract kernel headers
echo "Extracting kernel headers..."
dpkg-deb -x linux-headers.deb .

# Clone openvfd source
echo "Cloning openvfd source..."
git clone --depth 1 "$OPENVFD_REPO" openvfd-src

# Build kernel scripts
KERNEL_SRC="$BUILD_DIR/usr/src/linux-headers-$KERNEL_VERSION"
echo "Building kernel scripts..."
cd "$KERNEL_SRC"
make scripts ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
make M=scripts/mod ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-

# Build openvfd kernel module
echo "Building openvfd kernel module..."
cd "$BUILD_DIR/openvfd-src/driver"

# Patch Makefile for libgpiod
MAKEFILE=Makefile
if ! grep -q "CONFIG_OPENVFD_GPIOD" "$MAKEFILE"; then
    sed -i '/obj-m := openvfd.o/a\
EXTRA_CFLAGS += -DCONFIG_OPENVFD_GPIOD' "$MAKEFILE"
fi

make KERNELDIR="$KERNEL_SRC" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules

# Build OpenVFDService
echo "Building OpenVFDService..."
cd "$BUILD_DIR/openvfd-src"
aarch64-linux-gnu-gcc -Wall -o OpenVFDService OpenVFDService.c -lm -lpthread -static

# Copy results to output
echo "Build successful!"
OUTPUT_DIR="$(dirname "$BUILD_DIR")/output"
mkdir -p "$OUTPUT_DIR"
cp "$BUILD_DIR/openvfd-src/driver/openvfd.ko" "$OUTPUT_DIR/"
cp "$BUILD_DIR/openvfd-src/OpenVFDService" "$OUTPUT_DIR/"
echo "Kernel module saved to: $OUTPUT_DIR/openvfd.ko"
echo "OpenVFDService binary saved to: $OUTPUT_DIR/OpenVFDService"
ls -lh "$OUTPUT_DIR/openvfd.ko"
ls -lh "$OUTPUT_DIR/OpenVFDService"
file "$OUTPUT_DIR/openvfd.ko"
file "$OUTPUT_DIR/OpenVFDService"
