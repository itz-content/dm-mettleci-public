#!/bin/bash
# ==============================================================================
# Script: deploy-cp4d-datastage-5.3.1.sh
# Purpose: Deploys CCS and DataStage onto a CP4D 5.3.1 Cluster
# ==============================================================================

# 0. Source the environment variables
ENV_FILE="deploy-cp4d-cluster-vars.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    echo "==> Loaded variables from $ENV_FILE"
else
    echo "ERROR: Cannot find $ENV_FILE. Please run this script from the same directory."
    exit 1
fi

# ==============================================================================
# Download CASE Metadata
# ==============================================================================
echo "==> Downloading CASE metadata for release ${CPD_VERSION} patch ${PATCH_ID}..."

# Ensure the CLI knows exactly where to drop the files
export CPD_CLI_MANAGE_WORKSPACE="/home/itzuser/cpd-cli-workspace"

cpd-cli manage case-download \
    --release=${CPD_VERSION} \
    --patch_id=${PATCH_ID} \
    --components=${COMPONENTS} \
    --cluster_resources=true

oc apply -f ${CPD_CLI_MANAGE_WORKSPACE}/work/cluster_scoped_resources.yaml \
    --server-side \
    --force-conflicts

echo "==> Installing Operators for ${COMPONENTS}..."
cpd-cli manage apply-olm \
    --release=${CPD_VERSION} \
    --components=${COMPONENTS} \
    --cpd_operator_ns=cpd-operators

# 1. Install Unified Components (Operators + Custom Resources)
echo "==> Installing components: $COMPONENTS..."
cpd-cli manage install-components \
    --release=${CPD_VERSION} \
    --patch_id=${PATCH_ID} \
    --components=${COMPONENTS} \
    --operator_ns=${PROJECT_CPD_INST_OPERATORS} \
    --instance_ns=${PROJECT_CPD_INST_OPERANDS} \
    --block_storage_class=${STG_CLASS_BLOCK} \
    --file_storage_class=${STG_CLASS_FILE} \
    --license_acceptance=true

if [ $? -ne 0 ]; then
    echo "ERROR: Deployment failed. Please check the cpd-cli-workspace logs."
    exit 1
fi

echo "========================================================================="
echo "SUCCESS: Component installation initiated cleanly!"
echo "Check the provisioning status by running:"
echo "cpd-cli manage get-cr-status --instance_ns=${PROJECT_CPD_INST_OPERANDS} --components=${COMPONENTS}"
echo "========================================================================="