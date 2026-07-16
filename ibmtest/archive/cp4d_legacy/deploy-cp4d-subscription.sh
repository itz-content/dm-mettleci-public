#!/bin/bash
export KUBECONFIG="${HOME}/.kube/config"

echo "=========================================="
echo "Installing Cloud Pak for Data Platform Operator..."
echo "=========================================="

# Ensure the required namespace-scope ConfigMap exists before creating the subscription
if ! oc get configmap namespace-scope -n cp4d-operators --kubeconfig=$KUBECONFIG >/dev/null 2>&1; then
    echo "Required ConfigMap 'namespace-scope' not found. Creating it now..."
    oc create configmap namespace-scope -n cp4d-operators --from-literal=namespaces=cp4d-operators --kubeconfig=$KUBECONFIG
else
    echo "ConfigMap 'namespace-scope' already exists. Proceeding..."
fi

# Apply the local YAML file directly
oc apply -f cp4d-subscription.yml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Monitoring Operator Installation..."
echo "=========================================="

# Wait for OpenShift to generate the ClusterServiceVersion (CSV)
CSV_NAME=""
while [ -z "$CSV_NAME" ]; do
  echo "Waiting for OpenShift to generate the installation plan..."
  sleep 5
  # Grab the specific name of the generated CSV
  CSV_NAME=$(oc get csv -n cp4d-operators --no-headers --kubeconfig=$KUBECONFIG | grep cpd-platform-operator | awk '{print $1}' | head -n 1)
done

echo "Found installation package: $CSV_NAME"

# Track the live phase of the CSV
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
    echo "Current status: $PHASE... (checking again in 30 seconds)"
  fi
  sleep 30
done

echo "=========================================="
echo "Ensuring Operator Pod is Fully Ready..."
echo "=========================================="
# Step 1: Wait for OLM to actually create the deployment object
while ! oc get deployment cpd-platform-operator-manager -n cp4d-operators --kubeconfig=$KUBECONFIG >/dev/null 2>&1; do
  echo "Waiting for the deployment object... (checking again in 15s)"
  sleep 15
done

# Step 2: Wait for the pod to become fully Ready
echo "Operator deployment found! Waiting for the pod to pass health checks..."
oc rollout status deployment/cpd-platform-operator-manager -n cp4d-operators --kubeconfig=$KUBECONFIG --timeout=5m

# Step 3: Buffer for internal Ansible runner webhooks to settle
echo "Operator is Ready! Letting webhooks settle for 60 seconds..."
sleep 60