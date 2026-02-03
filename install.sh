#!/bin/bash
# OpenVFD Installation Script
# This script installs the OpenVFD kernel module and service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}OpenVFD Installation Script${NC}"
echo "================================"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if files exist
if [ ! -f "$SCRIPT_DIR/openvfd.ko" ]; then
    echo -e "${RED}Error: openvfd.ko not found in $SCRIPT_DIR${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/OpenVFDService" ]; then
    echo -e "${RED}Error: OpenVFDService not found in $SCRIPT_DIR${NC}"
    exit 1
fi

# Install kernel module
echo -e "${YELLOW}Installing kernel module...${NC}"
KERNEL_VERSION=$(uname -r)
MODULE_DIR="/lib/modules/$KERNEL_VERSION/kernel/drivers/misc"
mkdir -p "$MODULE_DIR"
cp "$SCRIPT_DIR/openvfd.ko" "$MODULE_DIR/"
depmod -a
echo -e "${GREEN}✓ Kernel module installed${NC}"

# Install OpenVFDService binary
echo -e "${YELLOW}Installing OpenVFDService binary...${NC}"
cp "$SCRIPT_DIR/OpenVFDService" /usr/local/bin/
chmod +x /usr/local/bin/OpenVFDService
echo -e "${GREEN}✓ OpenVFDService binary installed${NC}"

# Create configuration directory
echo -e "${YELLOW}Setting up configuration...${NC}"
CONFIG_DIR="/storage/.config"
if [ ! -d "$CONFIG_DIR" ]; then
    # Fallback to /etc if /storage doesn't exist
    CONFIG_DIR="/etc/openvfd"
    mkdir -p "$CONFIG_DIR"
fi

# Download TX92 configuration
echo -e "${YELLOW}Downloading TX92 VFD configuration...${NC}"
VFD_CONF_URL="https://raw.githubusercontent.com/arthur-liberman/vfd-configurations/master/tx92-vfd.conf"
if curl -sL "$VFD_CONF_URL" -o "$CONFIG_DIR/vfd.conf"; then
    echo -e "${GREEN}✓ Configuration downloaded to $CONFIG_DIR/vfd.conf${NC}"
else
    echo -e "${YELLOW}Warning: Could not download configuration file${NC}"
    echo -e "${YELLOW}You may need to configure manually${NC}"
fi

# Load kernel module
echo -e "${YELLOW}Loading kernel module...${NC}"
if modprobe openvfd; then
    echo -e "${GREEN}✓ Kernel module loaded${NC}"
else
    echo -e "${YELLOW}Warning: Could not load kernel module automatically${NC}"
    echo -e "${YELLOW}You may need to reboot or load it manually with: modprobe openvfd${NC}"
fi

# Create systemd service
echo -e "${YELLOW}Creating systemd service...${NC}"
cat > /etc/systemd/system/openvfd.service << 'EOF'
[Unit]
Description=OpenVFD Display Service
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/OpenVFDService
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable openvfd.service
echo -e "${GREEN}✓ Systemd service created and enabled${NC}"

# Start the service
echo -e "${YELLOW}Starting OpenVFDService...${NC}"
if systemctl start openvfd.service; then
    echo -e "${GREEN}✓ OpenVFDService started${NC}"
else
    echo -e "${YELLOW}Warning: Could not start service automatically${NC}"
    echo -e "${YELLOW}You may need to start it manually with: systemctl start openvfd.service${NC}"
fi

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation completed!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "Useful commands:"
echo "  - Check service status: systemctl status openvfd.service"
echo "  - View service logs: journalctl -u openvfd.service -f"
echo "  - Restart service: systemctl restart openvfd.service"
echo "  - Stop service: systemctl stop openvfd.service"
echo "  - Edit configuration: nano $CONFIG_DIR/vfd.conf"
echo ""
echo "Note: If the display doesn't work with TX92 configuration,"
echo "you may need to find the correct configuration for your device at:"
echo "https://github.com/arthur-liberman/vfd-configurations"
