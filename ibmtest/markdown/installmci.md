# Deploying and Configuring MettleCI Workbench on RHEL 9 Server

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install and Configure MettleCI Workbench (`install_mettleci.yml`)

This playbook deploys and configures the MettleCI Workbench, Unit Test Harness, and Command Shell on the RHEL 9 server node (`10.10.10.201`). It handles Java runtime setup, local RPM installations, license and configuration deployment, SSL certificate trust against DataStage services, Gitea SSH key integration, and service lifecycle management.

### 1. Java 11 Runtime Provisioning

- **Directory Setup:** Ensures the `/usr/lib/jvm` system directory exists.
- **Extraction & Alternatives:** Locates and extracts the OpenJDK tarball, registers Java 11 with the system `alternatives` framework, and sets it as the system default runtime.

### 2. MettleCI Workbench & Ecosystem RPM Installations

- **Workbench RPM Deployment:** Dynamically discovers and installs the MettleCI Workbench RPM (`dm-mettleci-workbench-*.rpm`) via DNF with GPG checks disabled.
- **Add-On Component Rollout:** Discovers and installs the MettleCI Unit Test Harness RPM (`dm-unittest-harness-*.rpm`) and Command Shell RPM (`dm-mettleci-command-shell-*.rpm`).

### 3. Directory Structure, Licensing & Configuration

- **Installation Paths:** Provisions `/opt/dm/mci` under strict ownership (`mciworkb:dstage`) and permissions (`0755`).
- **Asset Deployment:** Deploys the environment script (`setupEnv.sh`), the MettleCI license (`mettleci.lic` to both the main directory and the CLI subdirectory), and configuration files (`config.yml`, `project-settings.yaml`, and `datastage-users.yaml`).
- **RSA Key Generation:** Generates a secure 4096-bit RSA key pair (`workbench.key` / `workbench.key.pub`) idempotently using `ssh-keygen`, enforcing secure file permissions (`0600` for private, `0644` for public).

### 4. SSL Trust & Gitea Integration

- **DataStage Trust:** Dynamically locates the MettleCI UI JAR (`mettle-ui-*.jar`) and executes `java -jar ... trust-datastage config.yml` to trust the remote DataStage Services Tier certificate.
- **Gitea API Key Registration:** Reads the generated public SSH key (`workbench.key.pub`) from disk and automatically registers it to the `itzuser` Gitea profile via the REST API (`/api/v1/user/keys`) using basic authentication.

### 5. Service Lifecycle Management

- **Service Startup:** Starts the legacy MettleCI workbench service (`dm-mettleci-workbench`) while safely handling instances where the service is already running.
- **Handlers:** Configures a dedicated `restart mettleci` handler to cleanly stop, pause, and restart the service whenever core configuration files or licenses are updated.
