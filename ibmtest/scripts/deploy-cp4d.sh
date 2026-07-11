#!/bin/bash

# Exit immediately on any error
set -e

echo "Starting Full CP4D Deployment Pipeline..."

# 1. Setup Catalog
bash deploy-cp4d-catalog.sh

# 2. Deploy Operators & Infrastructure
bash deploy-cp4d-operators.sh

# 3. Deploy Platform Subscription
bash deploy-cp4d-subscription.sh

# 4. Deploy Control Plane Instance
bash deploy-cp4d-instance.sh

# 5. Deploy Datastage
bash deploy-cp4d-datastage.sh

echo "=========================================="
echo "Deployment Pipeline Completed Successfully."
echo "=========================================="