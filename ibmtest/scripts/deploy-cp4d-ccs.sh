#!/bin/bash

export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Installing Common Core Services Operator..."
echo "=========================================="
oc apply -f cp4d-ccs-operator.yml

echo "Waiting for CCS Operator to initialize (45 seconds)..."
sleep 45

echo "=========================================="
echo "Deploying Common Core Services (CCS)..."
echo "=========================================="
oc apply -f cp4d-ccs-cr.yml

echo "=========================================="
echo "Monitoring CCS Installation (takes 10-15 mins)..."
echo "=========================================="
while true; do
  CCS_STATUS=$(oc get ccs ccs-cr -n cpd -o jsonpath='{.status.ccsStatus}' 2>/dev/null)
  
  if [[ "$CCS_STATUS" == "Completed" ]]; then
    echo "CCS Status: Completed!"
    break
  elif [[ "$CCS_STATUS" == "Failed" ]]; then
    echo "Error: CCS deployment failed. Check the operator logs."
    exit 1
  else
    # If the status is blank while starting, default to "Initializing..."
    echo "CCS Status: ${CCS_STATUS:-Initializing...} (checking again in 30 seconds)"
  fi
  sleep 30
done

echo "=========================================="
echo "CCS Deployment Completed Successfully."
echo "=========================================="