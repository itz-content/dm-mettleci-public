#!/bin/bash
# IBM Information Server - Fresh Start Cleanup Script

echo "Stopping any lingering IBM processes..."
sudo pkill -9 -u dsadm 2>/dev/null
sudo pkill -9 -u db2inst1 2>/dev/null
sudo pkill -9 -u xmeta 2>/dev/null
sudo pkill -9 -u itzuser -f "java" 2>/dev/null

sudo userdel -r dsadm
sudo userdel -r db2inst1
sudo userdel -r db2fenc1
sudo userdel -r xmeta
sudo userdel -r xmetasr
sudo groupdel dstage
sudo groupdel db2iadm1
sudo groupdel db2fadm1

echo "Removing installation directories..."
sudo rm -rf /opt/IBM/InformationServer
sudo rm -rf /opt/IBM/WebSphere
sudo rm -rf /opt/ibm/db2

echo "Clearing IBM registries and inventory..."
sudo rm -rf /var/ibm/InstallationManager
sudo rm -rf /etc/ibm/InstallationManager
sudo rm -rf /etc/ibm/viewer

echo "Cleaning temporary files and and directories ..."
sudo rm -rf /tmp/ibm_is_logs
sudo rm -rf /tmp/is_temp
sudo rm -rf /tmp/is-suite
sudo rm -rf /tmp/responsems.txt
sudo rm -rf /mnt/second/IBM
sudo rm -rf /mnt/second/home/*
sudo rm -rf /mnt/second/is_temp
sudo rm -rf /tmp/is_home
sudo rm -rf /tmp/is-suite

echo "clear loitering ssh sessions..."
sudo pkill -f "sshd: \[accepted\]"
sudo pkill -f "sshd: \[net\]"

echo "Cleanup complete. System is ready for a fresh install."