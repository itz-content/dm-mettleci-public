#!/bin/bash

# Exit immediately on any error
set -e

echo "Starting Full CP4D Deployment Pipeline..."

# 1. Setup Catalog
./deploy-cp4d-catalog.sh

# 2. Deploy Operators & Infrastructure
./deploy-cp4d-operators.sh

# 3. Deploy Platform Subscription
./deploy-cp4d-subscription.sh

# 4. Deploy Control Plane Instance
./deploy-cp4d-instance.sh

echo "=========================================="
echo "Deployment Pipeline Completed Successfully."
echo "=========================================="