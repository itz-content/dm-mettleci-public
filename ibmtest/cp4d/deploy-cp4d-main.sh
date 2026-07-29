#!/bin/bash
set -e 

echo "Setting OpenShift kubeconfig permissions..."
chmod 644 ~/.kube/config

echo "Starting cpd-cli deployment..."
bash deploy-cp4d-cpd-cli.sh

echo "Starting DataStage deployment..."
bash deploy-cp4d-datastage-5.3.1.sh

echo "Waiting for the Cloud Pak for Data platform to be ready..."
while true; do
    STATUS=$(cpd-cli manage get-cr-status --cpd_instance_ns=cpd --components=cpd_platform \vert{} grep -i cpd_platform \vert{} awk '{print$NF}')
    
    if [[ "$STATUS" == "Completed" ]]; then
        echo "Cloud Pak for Data platform is ready!"
        break
    elif [[ "$STATUS" == "Failed" ]]; then
         echo "ERROR: Platform installation reported a Failed status."
         exit 1
    else
        echo "Current status: $STATUS. Checking again in 2 minutes..."
        sleep 120
    fi
done

echo "Fetching OpenShift Console details..."
cpd-cli manage get-cpd-instance-details \\
    --cpd_instance_ns=cpd \\
    --get_admin_initial_credentials=true