#!/bin/bash

echo "=========================================="
echo "Installing DataStage Operator..."
echo "=========================================="
oc apply -f cp4d-datastage-operator.yml --kubeconfig=/home/itzuser/kubeconfig

# Giving OLM time to read the subscription and generate the InstallPlan
echo "Waiting for DataStage Operator to initialize (45 seconds)..."
sleep 45

echo "=========================================="
echo "Deploying DataStage Engine..."
echo "=========================================="
# Reminder: Ensure <YOUR_STORAGE_CLASS> is updated in this YAML before running!
oc apply -f cp4d-datastage-cr.yml --kubeconfig=/home/itzuser/kubeconfig

echo "=========================================="
echo "Monitoring DataStage Installation..."
echo "=========================================="
while true; do
  STATUS=$(oc get datastage datastage-cr -n cpd -o jsonpath='{.status.dsStatus}' --kubeconfig=/home/itzuser/kubeconfig 2>/dev/null)
  
  if [[ "$STATUS" == "Completed" ]]; then
    echo "Success! DataStage is fully installed and running."
    break
  elif [[ "$STATUS" == "Failed" ]]; then
    echo "Error: DataStage deployment failed. Check the operator logs."
    break
  fi
  
  echo "DataStage Status: ${STATUS:-Initializing}... (checking again in 30 seconds)"
  sleep 60
done