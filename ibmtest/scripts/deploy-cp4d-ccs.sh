#!/bin/bash
set -e

# Tell cpd-cli how to authenticate with the cluster
export KUBECONFIG="/home/itzuser/kubeconfig"

CPD_VERSION="4.4.0"
OPERATOR_NS="cp4d-operators"
INSTANCE_NS="cpd"

echo "Authorizing instance topology..."
cpd-cli manage authorize-instance-topology \
  --cpd_operator_ns=${OPERATOR_NS} \
  --cpd_instance_ns=${INSTANCE_NS}

echo "Installing CCS Operator (OLM)..."
cpd-cli manage apply-olm \
  --release=${CPD_VERSION} \
  --cpd_operator_ns=${OPERATOR_NS} \
  --components=ccs

echo "Deploying CCS Custom Resource..."
cpd-cli manage apply-cr \
  --release=${CPD_VERSION} \
  --cpd_instance_ns=${INSTANCE_NS} \
  --components=ccs \
  --license_acceptance=true