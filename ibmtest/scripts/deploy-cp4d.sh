#!/bin/bash

# Exit immediately on any error
set -e
export KUBECONFIG=~/.kube/config

echo "Starting Full CP4D Deployment Pipeline..."

# 1. Deploy CLI
bash deploy-cp4d-cli.sh
# Explicitly load the CLI path into this running script
export PATH="$PATH:$HOME/cpd-cli-tool"

# 2. Setup Catalog
bash deploy-cp4d-catalog.sh

# 3. Deploy Operators & Infrastructure
bash deploy-cp4d-operators.sh

# 4. Deploy Platform Subscription
bash deploy-cp4d-subscription.sh

# 5. Deploy Control Plane Instance
bash deploy-cp4d-instance.sh

echo "=========================================="
echo "Waiting for ZenService to reach 'Completed' state..."
echo "Checking every 5 minutes. Feel free to step away."
echo "=========================================="

while true; do
  STATUS=$(oc get zenservice lite-cr -n cpd --kubeconfig=/home/itzuser/kubeconfig -o jsonpath='{.status.zenStatus}' 2>/dev/null || echo "Waiting")
  CURRENT_TIME=$(date +'%H:%M:%S')
  
  if [ "$STATUS" == "Completed" ]; then
    echo "[$CURRENT_TIME] ZenService is Completed. Base platform is healthy."
    break
  elif [ "$STATUS" == "Failed" ]; then
    echo "[$CURRENT_TIME] ERROR: ZenService deployment failed."
    exit 1
  else
    echo "[$CURRENT_TIME] Status is ${STATUS:=Provisioning}. Checking again in 5 minutes..."
    sleep 300
  fi
done

echo "=========================================="
echo "Deployment Pipeline Completed Successfully."
echo "=========================================="