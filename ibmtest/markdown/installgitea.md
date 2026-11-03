# Deploying and Configuring Gitea on RHEL 9 with PostgreSQL Integration

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install Gitea (`install_gitea.yml`)

This playbook deploys and configures Gitea natively on RHEL 9 as the local Git repository hosting service. It provisions a dedicated PostgreSQL database, deploys the binary, seeds the configuration file to bypass the web installer, sets up a systemd service, and automatically bootstraps the administrative user.

### 1. Database & System User Provisioning

- **PostgreSQL Setup:** Creates the dedicated `gitea` database role and `gitea` database owned by that user if they do not already exist.
- **Git Package & User:** Ensures `git` is installed via DNF and creates the dedicated system user `git` with home directory `/home/git`.

### 2. Directory Structure & Binary Placement

- **Directory Setup:** Creates required Gitea state, custom, data, log, and configuration directories (`/var/lib/gitea`, `/etc/gitea`) with strict `git:git` permissions (`0750`).
- **Binary Deployment:** Copies the staged Gitea binary to `/usr/local/bin/gitea` with executable permissions (`0755`).

### 3. Configuration & Systemd Integration

- **Seeding **`app.ini`**:** Writes a baseline configuration file to `/etc/gitea/app.ini` pointing to the local PostgreSQL instance, configuring server port `53000`, binding the domain IP, and locking the installation phase (`INSTALL_LOCK = true`).
- **Systemd Service:** Deploys a managed `gitea.service` unit file tied to network and PostgreSQL startup dependencies, executing under the `git` user context.
- **Firewall Configuration:** Opens port `53000/tcp` permanently in the RHEL 9 system firewall.

### 4. Service Startup & Admin Bootstrap

- **Service Lifecycle:** Reloads systemd daemon and enables/starts the `gitea` service.
- **Health Check:** Polls the local web service endpoint on port `53000` until it confirms availability.
- **Admin User Creation:** Invokes the Gitea CLI (`admin user create`) to automatically provision the primary administrator account (`itzuser`) without requiring manual web UI setup.
