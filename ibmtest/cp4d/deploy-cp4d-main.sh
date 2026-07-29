#!/bin/bash

echo "Setting OpenShift kubeconfig permissions..."
chmod 644 ~/.kube/config

echo "Starting cpd-cli deployment..."
bash deploy-cp4d-cpd-cli.sh

echo "Starting DataStage deployment..."
bash deploy-cp4d-datastage-5.3.1.sh

echo "Deployment scripts finished. Fetching OpenShift Console details..."
cpd-cli manage get-cpd-instance-details \
    --cpd_instance_ns=cpd \
    --get_admin_initial_credentials=true