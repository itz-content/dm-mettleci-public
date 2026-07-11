#!/bin/bash

#!/bin/bash

export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Installing Common Core Services Operator..."
echo "=========================================="
oc apply -f cp4d-ccs-operator.yml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Waiting for CCS API to register..."
echo "=========================================="
# Dynamically poll the API instead of a hardcoded sleep
while ! oc api-resources --kubeconfig=$KUBECONFIG | grep -q "ccs.cpd.ibm.com"; do
  echo "CCS API not ready yet. Checking again in 30 seconds..."
  sleep 30
done

# Add a tiny buffer to ensure the operator's backend webhooks are fully awake
echo "API registered! Giving the controller 15 seconds to stabilize..."
sleep 15

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
    echo "CCS Status: ${CCS_STATUS:-Initializing...} (checking again in 30 seconds)"
  fi
  sleep 30
done

echo "=========================================="
echo "CCS Deployment Completed Successfully."
echo "=========================================="