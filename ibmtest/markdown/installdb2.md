# Db2 Installation and Network Configuration Playbook for RHEL 9

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install Db2 (`install_db2.yml`)

This playbook handles the standalone installation and network configuration of the IBM Db2 database engine from the binaries unpacked during Phase 1. It prepares the host environment, executes the silent installation installer, configures TCP/IP communication protocols, and verifies socket readiness.

### 1. Prerequisite OS Libraries

Ensures all required runtime libraries and dependencies are present on the RHEL 9 system prior to database deployment:

- Installs `libaio`, `glibc`, `libgcc`, `libstdc++`, `pam`, and `numactl-libs`.

### 2. Security & Installation Prep

- **Response File Templating:** Generates the automated response file from `./templates/db2_server.rsp.j2` to `/tmp/db2_server.rsp` with the necessary passwords and configuration parameters.
- **Security Guardrails:** Temporarily disables SELinux (`setenforce 0`) and halts the `fapolicyd` systemd service to prevent security hooks from blocking deep low-level binary hooks during the enterprise installation.

### 3. Execution of Silent Db2 Setup

- **Asynchronous Engine Execution:** Runs `./db2setup` against the response file from the extracted path (`/opt/IBM/InformationServer/db2_extracted/server_dec`).
- **Timeout Controls:** Utilizes an asynchronous runner (`async: 1200`, `poll: 30`) capped at 20 minutes to prevent SSH session drops.
- **Exit Code Handling:** Accepts return codes `0` (Success) and `1` (Non-fatal warnings) while automatically failing on any other error code.

### 4. Network Configuration & Protocol Binding

Once the engine files are laid down, the playbook configures Db2 network listeners:

- **TCP/IP Protocol:** Sources the database profile for `db2inst1` and sets `DB2COMM=TCPIP`.
- **Port Mapping:** Injects the `db2c_db2inst1` service mapping (`50000/tcp`) into `/etc/services`.
- **Service Name Update:** Updates the database manager configuration (`SVCENAME`) to point to the mapped port string.
- **Connection & Engine Reset:** Resets the Ansible connection to flush the Name Service Switch (NSS) cache, then forces a restart (`db2stop force` / `db2start`) of the Db2 instance to bind the port.

### 5. Security Restoration & Port Verification

- **Re-enabling Security:** Restores the `fapolicyd` service and re-enables enforcing SELinux (`setenforce 1`).
- **Port Gatekeeper:** Uses `wait_for` to actively verify that port `50000` is open and listening, ensuring the database instance is fully online and ready for IBM Information Server repository connections.
