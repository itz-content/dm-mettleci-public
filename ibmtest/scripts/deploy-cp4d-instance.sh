#!/bin/bash
export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Preparing Cloud Pak for Data Instance..."
echo "=========================================="

# 1. Ensure the instance namespace exists
if ! oc get namespace cp4d-instance --kubeconfig=$KUBECONFIG >/dev/null 2>&1; then
    echo "Namespace 'cp4d-instance' not found. Creating it now..."
    oc create namespace cp4d-instance --kubeconfig=$KUBECONFIG
else
    echo "Namespace 'cp4d-instance' already exists. Proceeding..."
fi

echo "=========================================="
echo "Installing Cloud Pak for Data Control Plane..."
echo "=========================================="

# 2. Apply the YAML blueprint
oc apply -f cp4d-instance.yml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Monitoring Installation (This phase takes 45-60+ mins)..."
echo "=========================================="

PREV_STATUS=""
TICK=0

while true; do
  STATUS=$(oc get Ibmcpd ibmcpd-cr -n cp4d-instance -o jsonpath='{.status.controlPlaneStatus}' 2>/dev/null)
  
  # Handle empty status during initial boot
  if [ -z "$STATUS" ]; then
      STATUS="Initializing"
  fi

  # Trigger screen output ONLY if status changes OR every 10 ticks (5 minutes)
  if [ "$STATUS" != "$PREV_STATUS" ] || [ $((TICK % 10)) -eq 0 ]; then
    TIMESTAMP=$(date '+%H:%M:%S')
    
    if [ "$STATUS" == "Completed" ]; then
      echo "[$TIMESTAMP] Success! The Cloud Pak for Data instance is fully built and running."
      break
    elif [ "$STATUS" == "Failed" ]; then
      echo "[$TIMESTAMP] Error: Installation failed! Please check the OpenShift Console."
      exit 1
    else
      echo "[$TIMESTAMP] Current status: $STATUS (Next update on change or in 5 mins...)"
    fi
    
    PREV_STATUS="$STATUS"
  fi
  
  ((TICK++))
  sleep 30
done