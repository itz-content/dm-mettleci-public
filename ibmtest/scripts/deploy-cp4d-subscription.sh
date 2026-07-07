#!/bin/bash
export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Installing Cloud Pak for Data Platform Operator..."
echo "=========================================="

# Apply the local YAML file directly
oc apply -f cp4d-subscription.yaml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Monitoring Operator Installation..."
echo "=========================================="

# 1. Wait for OpenShift to generate the ClusterServiceVersion (CSV)
CSV_NAME=""
while [ -z "$CSV_NAME" ]; do
  echo "Waiting for OpenShift to generate the installation plan..."
  sleep 5
  # Grab the specific name of the generated CSV
  CSV_NAME=$(oc get csv -n cp4d-operators --no-headers --kubeconfig=$KUBECONFIG | grep ibm-cpd-platform-operator | awk '{print $1}' | head -n 1)
done

echo "Found installation package: $CSV_NAME"

# 2. Track the live phase of the CSV
while true; do
  # Extract the exact phase status using jsonpath
  PHASE=$(oc get csv $CSV_NAME -n cp4d-operators --kubeconfig=$KUBECONFIG -o jsonpath='{.status.phase}' 2>/dev/null)
  
  if [ "$PHASE" == "Succeeded" ]; then
    echo "Success! $CSV_NAME is fully installed and running."
    break
  elif [ "$PHASE" == "Failed" ]; then
    echo "Error: Installation failed! Please check the OpenShift Console."
    exit 1
  elif [ -z "$PHASE" ]; then
    echo "Current status: Initializing..."
  else
    echo "Current status: $PHASE... (checking again in 10 seconds)"
  fi
  sleep 10
done