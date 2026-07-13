#!/bin/bash

export KUBECONFIG=/home/itzuser/kubeconfig

echo "Waiting for the platform operator to register the CCS CRD..."
until oc get crd ccs.ccs.cpd.ibm.com >/dev/null 2>&1; do
  echo "CCS CRD not found yet. Waiting 30 seconds..."
  sleep 30
done
echo "CCS CRD is ready! Proceeding with deployment..."

echo "=========================================="
echo "Deploying Common Core Services (CCS)..."
echo "=========================================="
oc apply -f cp4d-ccs-cr.yml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Monitoring CCS Installation (takes 10-15 mins)..."
echo "=========================================="
while true; do
  CCS_STATUS=$(oc get ccs ccs-cr -n cpd -o jsonpath='{.status.ccsStatus}' --kubeconfig=$KUBECONFIG 2>/dev/null)
  
  if [[ "$CCS_STATUS" == "Completed" ]]; then
    echo "CCS Status: Completed!"
    break
  elif [[ "$CCS_STATUS" == "Failed" ]]; then
    echo "Error: CCS deployment failed. Check the operator logs."
    exit 1
  else
    echo "CCS Status: ${CCS_STATUS:-Initializing...} (checking again in 2 minutes)"
  fi
  sleep 120
done

echo "=========================================="
echo "CCS Deployment Completed Successfully."
echo "=========================================="