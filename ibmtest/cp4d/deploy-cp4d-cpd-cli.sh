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

# Extract Binary
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