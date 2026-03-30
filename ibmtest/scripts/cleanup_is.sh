#!/bin/bash
# IBM Information Server - Fresh Start Cleanup Script

echo "Stopping any lingering IBM processes..."
sudo pkill -9 -u dsadm 2>/dev/null
sudo pkill -9 -u db2inst1 2>/dev/null
sudo pkill -9 -u itzuser -f "java" 2>/dev/null

echo "Removing installation directories..."
sudo rm -rf /opt/IBM/InformationServer
sudo rm -rf /opt/IBM/WebSphere
sudo rm -rf /opt/ibm/db2

echo "Clearing IBM registries and inventory..."
sudo rm -rf /var/ibm/InstallationManager
sudo rm -rf /etc/ibm/InstallationManager
sudo rm -rf /etc/ibm/viewer

echo "Cleaning temporary files and logs..."
sudo rm -rf /tmp/ibm_is_logs
sudo rm -rf /tmp/is_temp
sudo rm -rf /tmp/is-suite
sudo rm -rf /tmp/responsems.txt

sudo pkill -f "sshd: \[accepted\]"
sudo pkill -f "sshd: \[net\]"

echo "Cleanup complete. System is ready for a fresh install."