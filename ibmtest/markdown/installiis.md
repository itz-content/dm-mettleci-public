# Silent Installation of IBM Information Server 11\.7\.1\.6 on RHEL 9 with Multi\-Tier Deployment

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install IIS Tiers (`install_iis_tiers.yml`)

This playbook orchestrates the complex, multi-tier silent installation of IBM Information Server 11.7.1.6 on RHEL 9. It executes the deployment across three discrete operational tiers—Repository, Services, and Engine—while managing environment constraints, security boundary flags, and post-installation configurations.

### 1. Pre-Flight Cleaning & Environment Normalization

- **Process Purging:** Terminates any stale IBM installer processes or rogue Java handlers running under `itzuser`.
- **Lock & Temp Cleanup:** Wipes residual installation locks, temp directories, logs, and user cache trees (`~/.isi/`) to ensure a pristine installation state.
- **Host Standardization:** Re-maps IPv4/IPv6 loopback lines in `/etc/hosts` and appends the active internal TechZone IP (`10.10.x.x`) to prevent WebSphere loopback binding errors.
- **Security Bounds:** Temporarily sets SELinux to `permissive` (`setenforce 0`) and halts `fapolicyd` to allow deep background binary hooks to run cleanly.

### 2. Tier 1: Repository Deployment & Xmeta Tuning

- **Silent Execution:** Runs `./setup` using the repository response file (`/tmp/repo.rsp`) with an asynchronous timeout wrapper (`async: 7200`) and localization environment variables (`LC_ALL=en_US.UTF-8`).
- **Validation:** Connects via `db2inst1` to verify the `xmeta` schema table structures exist.
- **Log Sizing & Tuning:** Updates the `xmeta` database log file size (`LOGFILSIZ 32768`) and bounces the Db2 instance to accommodate heavy repository initialization traffic.

### 3. Services Tier Deployment & WebSphere Configuration

- **Silent Execution:** Deploys the WebSphere and Services tier (`/tmp/services.rsp`) asynchronously with an extended window (`async: 14400`).
- **ODF Kafka Integration:** Configures the Open Data Framework (ODF) Kafka bootstrap servers key via `iisAdmin.sh` to route to `localhost:59092`.
- **Validation:** Confirms the WebSphere Java runtime process is actively running in the process tree.

### 4. Engine Tier Deployment & DataStage Setup

- **Silent Execution:** Deploys the core DataStage Engine tier (`/tmp/engine.rsp`) asynchronously.
- **RPC Daemon Validation:** Scans the network socket table (`ss -tln`) to ensure the RPC daemon is listening on port `31538`.
- **CLI & Connectivity Symlinks:**
    - Creates a global system symlink for `istool.sh` at `/usr/bin/istool.sh` for easy CI/CD integration.
    - Deploys a hidden `.odbc.ini` configuration file into the `dsadm` home tree (`/opt/IBM/InformationServer/Server/DSEngine/`) tailored for DataStage-to-PostgreSQL connectivity.

### 5. Post-Installation Security Restoration

- Restores the active `fapolicyd` systemd service.
- Re-enables enforcing SELinux state dynamically (`setenforce 1`) and persistently updates `/etc/selinux/config` back to `SELINUX=enforcing`.
- Outputs a deployment summary logging the return codes for all three execution tiers.
