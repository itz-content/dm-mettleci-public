#!/bin/bash
set -e

CPD_CLI_VERSION="12.0.4"
TOOL_DIR="$HOME/cpd-cli-tool"

echo "Configuring system PATH in ~/.bashrc..."
# Add to .bashrc only if it isn't already there
if ! grep -q "${TOOL_DIR}" ~/.bashrc; then
    echo -e "\n# IBM cpd-cli path" >> ~/.bashrc
    echo "export PATH=\"\$PATH:${TOOL_DIR}\"" >> ~/.bashrc
fi

# Apply the path immediately for this script's execution
export PATH="$PATH:${TOOL_DIR}"

echo "Checking for existing cpd-cli installation..."
if command -v cpd-cli >/dev/null 2>&1; then
    echo "cpd-cli is already installed."
    cpd-cli version
    echo "---"
    echo "Note: If cpd-cli is not found in your terminal, run 'source ~/.bashrc'"
    exit 0
fi

echo "Creating installation directory: ${TOOL_DIR}..."
mkdir -p "${TOOL_DIR}"

echo "Downloading cpd-cli v${CPD_CLI_VERSION}..."
wget -q "https://github.com/IBM/cpd-cli/releases/download/v${CPD_CLI_VERSION}/cpd-cli-linux-EE-${CPD_CLI_VERSION}.tgz" -O /tmp/cpd-cli.tgz

echo "Extracting cpd-cli..."
tar -xzf /tmp/cpd-cli.tgz -C "${TOOL_DIR}" --strip-components=1

echo "Cleaning up temporary files..."
rm -f /tmp/cpd-cli.tgz

echo "Verifying installation..."
cpd-cli version

echo "---"
echo "cpd-cli installation complete."
echo "Note: If cpd-cli is not found in your terminal, run 'source ~/.bashrc'"