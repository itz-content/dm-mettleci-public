#!/bin/bash

echo "Authorizing instance topology..."
cpd-cli manage authorize-instance-topology \
  --cpd_operator_ns=cp4d-operators \
  --cpd_instance_ns=cpd

echo "Installing CCS Operator (OLM)..."
cpd-cli manage apply-olm \
  --release=4.4.0 \
  --cpd_operator_ns=cp4d-operators \
  --components=ccs

echo "Deploying CCS Custom Resource..."
cpd-cli manage apply-cr \
  --release=4.4.0 \
  --cpd_instance_ns=cpd \
  --components=ccs \
  --license_acceptance=true