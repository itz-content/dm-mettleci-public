#!/bin/bash

# Exit immediately if a pipeline step fails
set -e 

echo "Setting OpenShift kubeconfig permissions..."
chmod 644 ~/.kube/config

echo "Starting cpd-cli deployment..."
# If this script fails, the 'set -e' above will stop the main script right here.
bash deploy-cp4d-cpd-cli.sh

echo "Starting DataStage deployment..."
# Initiates the component install.
bash deploy-cp4d-datastage-5.3.1.sh

echo "Waiting for the Cloud Pak for Data platform to be ready (this can take 30-60 minutes)..."

# Poll the cluster every 2 minutes (120 seconds) until it reports 'Completed'
# Note: We are checking 'cpd_platform', not DataStage, because we just need the console to be up.
while true; do
    STATUS=$(cpd-cli manage get-cr-status --cpd_instance_ns=cpd --components=cpd_platform | grep -i cpd_platform | awk '{print $NF}')
    
    if [[ "$STATUS" == "Completed" ]]; then
        echo "Cloud Pak for Data platform is ready!"
        break
    elif [[ "$STATUS" == "Failed" ]]; then
         echo "ERROR: Platform installation reported a Failed status. Exiting wait loop."
         exit 1
    else
        echo "Current status: $STATUS. Checking again in 2 minutes..."
        sleep 120
    fi
done

echo "Deployment finished. Fetching OpenShift Console details..."
cpd-cli manage get-cpd-instance-details \
    --cpd_instance_ns=cpd \
    --get_admin_initial_credentials=true