#!/bin/bash
export KUBECONFIG=/home/itzuser/kubeconfig

echo "=========================================="
echo "Installing Cloud Pak for Data Platform Operator..."
echo "=========================================="

# Apply the local YAML file directly
oc apply -f cp4d-subscription.yml --kubeconfig=$KUBECONFIG

echo "=========================================="
echo "Waiting for Operator Installation to Complete..."
echo "=========================================="

# Loop until the ClusterServiceVersion (CSV) shows 'Succeeded'
until oc get csv -n cp4d-operators --kubeconfig=$KUBECONFIG | grep ibm-cpd-platform-operator | grep -i "Succeeded" &> /dev/null
do
  echo "Waiting for operator to initialize (this takes 2-3 minutes)..."
  sleep 10
done

echo "Success! Cloud Pak for Data Operator is installed and running."