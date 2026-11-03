# Windows Client Bootstrap Script for Automated IBM DataStage Installation and Configuration

**Parent Page:** ([Deployment Pipeline Architecture Overview](DeploymentPipelineArchitectureOverview.md))

## Windows Client Bootstrap Script (`ds_silent_install_cli.ps1`)

**Parent Page:** \[Architecture Overview: `vm_map_string` & Pipeline Initialization\]

This PowerShell script serves as the primary execution engine launched during the Windows TechZone virtual machine's initial boot sequence (governed by `vm_map_string`). It automates environment preparation, S3 binary synchronization, OpenSSH key hardening, WinSCP and pgAdmin tooling installation, and the silent rollout of the IBM DataStage Client and CLI framework.

### 1. Transcript Logging & Variable Parsing

- **Transcript Recording:** Initializes an automated session log at `C:\is_temp\master_deployment_script.log` to capture all console output for auditing and troubleshooting.
- **Credential & Endpoint Ingestion:** Parses the TechZone variables file (`C:\Temp\post_deploy_repo\post_deploy_variables.json`) from disk to dynamically populate environment variables for secure S3 synchronization (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ENDPOINT_URL`, and `AWS_BUCKET_NAME`).

### 2. S3 Asset Synchronization & Tooling Deployment

Utilizing the AWS CLI, the script pulls all requisite binaries and configuration assets from cloud object storage into local temporary staging directories (`C:\is_temp`):

- **AWS CLI & WinSCP:** Installs the AWS CLI v2 silently if missing and deploys WinSCP (`WinSCP-6.5.6-Setup.exe`) via automated silent switches.
- **pgAdmin 4:** Checks for an existing installation and silently deploys pgAdmin (`pgadmin4-installer.exe`) for database management.
- **MettleCI & DataStage Payloads:** Pulls down the MettleCI license (`mettleci.lic`), the MettleCI custom installer (`MCI_Setup.exe`), the serialized DataStage ISX package (`jenkins_devops_techzone.isx`), and the core client archive (`IS_V11.7.1.6_WINDOWS_CLIENT.zip`).

### 3. OpenSSH & Key Security Hardening

- **SSH Directory Provisioning:** Establishes the `.ssh` directory structure for the `itzuser` account and creates a desktop shortcut (`vm_ssh_key.lnk`) for convenient developer access.
- **Public Key Integration:** Downloads the public SSH key (`CommKey.pub`), appends it to the Windows OpenSSH administrative authorized keys file (`C:\ProgramData\ssh\administrators_authorized_keys`), and restarts the SSH service (`sshd`).
- **Strict Access Control:** Enforces strict security inheritance stripping via `icacls`, granting exclusive Full Control permissions solely to `SYSTEM` and `Administrators`.

### 4. Silent DataStage Client Installation & Port Mapping

- **Archive Extraction:** Extracts the heavy DataStage client media ZIP using native Windows `tar.exe` into `C:\is_temp\IS_Client_Extract`.
- **Response File Relocation:** Copies the pre-configured silent response file (`ds_client.rsp`) directly into the extraction target alongside `setup.exe`.
- **Silent Execution & Monitoring:** Invokes `setup.exe` in silent mode (`-rsp` and `-verbose`), monitoring background Java and installer processes to ensure complete installation stability.
- **Network Service Mapping:** Updates the local Windows services file (`C:\Windows\System32\drivers\etc\services`) to bind the DataStage RPC (`dsrpc`) explicitly to port `80` to match the target server architecture configuration.
