#!/usr/bin/env bash
set -e

# Load environment variables
ENV_FILE="deploy-cp4d-cluster-vars.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
    echo "==> Loaded variables from $ENV_FILE"
else
    echo "ERROR: Cannot find $ENV_FILE."
    exit 1
fi

# Internal Script Paths
DOWNLOAD_DIR="/home/itzuser"
INSTALL_DIR="/home/itzuser/cpd-cli-tool"
WORKSPACE_DIR="/home/itzuser/cpd-cli-workspace"

# ==============================================================================
# Configure OS for Rootless Podman
# ==============================================================================
echo "==> Configuring user namespaces for rootless Podman..."
sudo sysctl -w user.max_user_namespaces=65536

# Make it persistent across bastion reboots
echo "user.max_user_namespaces=65536" | sudo tee /etc/sysctl.d/99-userns.conf > /dev/null

# ==============================================================================
# Fetch CPD CLI from S3 / IBM Cloud Object Storage
# ==============================================================================
echo "==> Checking for AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "[INFO] AWS CLI not found. Installing official AWS CLI v2 via curl..."
    
    # Ensure unzip is available to extract the AWS package
    if ! command -v unzip &> /dev/null; then
        sudo dnf install -y unzip
    fi

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip ./aws
    echo "[INFO] AWS CLI installation complete."
fi

# Add permissions for itzuser
sudo chmod -R 755 /usr/local/aws-cli
sudo chmod 755 /usr/local/bin/aws

# Setup AWS credentials from the securely transferred file
echo "Configuring AWS credentials..."
mkdir -p ~/.aws
if [ -f ~/secrets.aws ]; then
    mv ~/secrets.aws ~/.aws/credentials
    chmod 600 ~/.aws/credentials
else
    echo "[ERROR] secrets.aws not found in home directory! Cannot download cpd-cli."
    exit 1
fi

echo "==> Downloading ${CPD_CLI_BINARY} from S3 bucket ${AWS_BUCKET_NAME}/binaries..."
/usr/local/bin/aws --endpoint-url="${AWS_ENDPOINT_URL}" s3 cp "s3://${AWS_BUCKET_NAME}/binaries/${CPD_CLI_BINARY}" "${DOWNLOAD_DIR}/${CPD_CLI_BINARY}"

# ==============================================================================
# Extract and Configure Binary
# ==============================================================================
echo "[INFO] Extracting ${CPD_CLI_BINARY} from ${DOWNLOAD_DIR} to ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}"

tar -xvf "${DOWNLOAD_DIR}/${CPD_CLI_BINARY}" -C "${INSTALL_DIR}" --strip-components=1 2>/dev/null || \
tar -xvf "${DOWNLOAD_DIR}/${CPD_CLI_BINARY}" -C "${INSTALL_DIR}"

# Set Runtime Environment for the current script session
export PATH="${INSTALL_DIR}:${PATH}"
export CPD_CLI_MANAGE_WORKSPACE="${WORKSPACE_DIR}"

# Make the CLI permanently available for interactive sessions
echo "[INFO] Updating ~/.bashrc with the cpd-cli path..."
if ! grep -q "${INSTALL_DIR}" ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo "# IBM Cloud Pak for Data CLI" >> ~/.bashrc
  echo "export PATH=${INSTALL_DIR}:\$PATH" >> ~/.bashrc
  echo "export CPD_CLI_MANAGE_WORKSPACE=${WORKSPACE_DIR}" >> ~/.bashrc
  echo "[INFO] Path and Workspace added to ~/.bashrc."
else
  echo "[INFO] ~/.bashrc already contains the cpd-cli path. Skipping."
fi

# Apply the bashrc changes to the current environment (if supported by the shell)
source ~/.bashrc || true

# Verify Engine
echo "[INFO] Verifying installed CLI binary version..."
cpd-cli version

# ==============================================================================
# PHASE: Cluster Preparation & OLM Installation
# ==============================================================================
echo "[INFO] Starting Cluster Preparation for OpenShift..."

# Define your deployment variables
export CPD_VERSION="5.0.0" # Update this to match your target version
export OLM_NAMESPACE="cpd-operators"
export INSTANCE_NAMESPACE="cpd-instance"
export COMPONENTS="cpfs,zen,datastage" # Update with your specific component IDs

echo "==> 1. Ensuring IBM Operator Catalog is present in the cluster..."
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: IBM Operator Catalog
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/ibm-operator-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "==> Waiting for ibm-operator-catalog to become READY..."
sleep 10
oc wait --for=condition=Ready catalogsource/ibm-operator-catalog -n openshift-marketplace --timeout=300s

echo "==> 2. Setting up instance topology (Namespaces and RBAC)..."
cpd-cli manage setup-instance-topology \
  --cpd_operator_ns="${OLM_NAMESPACE}" \
  --cpd_instance_ns="${INSTANCE_NAMESPACE}" \
  --license_acceptance=true

echo "==> 3. Applying OLM (Deploying Operators into ${OLM_NAMESPACE})..."
cpd-cli manage apply-olm \
  --release="${CPD_VERSION}" \
  --cpd_operator_ns="${OLM_NAMESPACE}" \
  --components="${COMPONENTS}"

echo "[SUCCESS] Cluster preparation complete! Operators are standing by."
