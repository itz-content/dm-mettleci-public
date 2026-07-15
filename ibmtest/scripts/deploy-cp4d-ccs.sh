#!/bin/bash
#!/bin/bash
set -e

CPD_VERSION="4.4.0"
OPERATOR_NS="cpd-operators"
INSTANCE_NS="cpd"

echo "----------------------------------------------------"
echo "1. Installing CCS Operator (OLM)..."
echo "----------------------------------------------------"
cpd-cli manage apply-olm \
  --release="${CPD_VERSION}" \
  --cpd_operator_ns="${OPERATOR_NS}" \
  --components=ccs \
  --license_acceptance=true

echo "----------------------------------------------------"
echo "2. Deploying CCS Custom Resource..."
echo "----------------------------------------------------"
cpd-cli manage apply-cr \
  --release="${CPD_VERSION}" \
  --cpd_instance_ns="${INSTANCE_NS}" \
  --components=ccs \
  --license_acceptance=true