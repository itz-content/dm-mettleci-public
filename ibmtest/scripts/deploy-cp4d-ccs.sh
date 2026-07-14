#!/bin/bash
set -e
export KUBECONFIG=~/.kube/config

# Force cpd-cli to use the CPD 4.x compatible utility image
export OLM_UTILS_IMAGE="icr.io/cpopen/cpd/olm-utils-v2:latest"

CPD_VERSION="4.4.0"
OPERATOR_NS="cp4d-operators"
INSTANCE_NS="cpd"

echo "----------------------------------------------------"
echo "1. Authorizing instance topology..."
echo "----------------------------------------------------"
cpd-cli manage authorize-instance-topology \
  --cpd_operator_ns=${OPERATOR_NS} \
  --cpd_instance_ns=${INSTANCE_NS}

echo "----------------------------------------------------"
echo "2. Installing CCS Operator (OLM)..."
echo "----------------------------------------------------"
cpd-cli manage apply-olm \
  --release=${CPD_VERSION} \
  --cpd_operator_ns=${OPERATOR_NS} \
  --components=ccs

echo "----------------------------------------------------"
echo "3. Deploying CCS Custom Resource..."
echo "----------------------------------------------------"
cpd-cli manage apply-cr \
  --release=${CPD_VERSION} \
  --cpd_instance_ns=${INSTANCE_NS} \
  --components=ccs \
  --license_acceptance=true