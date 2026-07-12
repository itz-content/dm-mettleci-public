#!/bin/bash

export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Installing Common Core Services Operator..."
echo "=========================================="
oc apply -f cp4d-ccs-operator.yml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Waiting for CCS Operator Pod to be Ready..."
echo "=========================================="
# Step 1: Wait for OLM to create the CCS deployment
while ! oc get deployment ibm-cpd-ccs-operator -n cp4d-operators --kubeconfig=$KUBECONFIG >/dev/null 2>&1; do
  echo "Waiting for OLM to provision the CCS operator... (checking again in 15s)"
  sleep 15
done

# Step 2: Wait for the pod to become Ready
echo "CCS Operator deployment found! Waiting for the pod to become fully Ready..."
oc rollout status deployment/ibm-cpd-ccs-operator -n cp4d-operators --kubeconfig=$KUBECONFIG --timeout=5m

echo "Operator is Ready! Letting webhooks settle for 60 seconds..."
sleep 60

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