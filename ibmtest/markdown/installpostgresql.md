# Deploying and Configuring PostgreSQL on RHEL 9 for DevOps Toolchain

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install PostgreSQL (`install_postgresql.yml`)

This playbook deploys and configures PostgreSQL on RHEL 9 to serve as the backend database infrastructure for the DevOps toolchain and demonstration datasets.

### 1. PostgreSQL Module & Package Installation

- **Module Stream Reset:** Resets and enables the PostgreSQL stream (`postgresql:18`) via DNF.
- **Package Deployment:** Installs `postgresql` (client tools like `pg_restore`) and `postgresql-server` (database engine), forcing an upgrade over baseline image defaults.

### 2. Cluster Initialization & Network Configuration

- **Database Cluster Setup:** Initializes the PostgreSQL data directory using `postgresql-setup --initdb`.
- **Network Binding:** Configures `listen_addresses = '*'` in `postgresql.conf` to allow remote connections.
- **Client Access Control (**`pg_hba.conf`**):**
    - Grants `md5` authenticated access to the Windows client (`10.10.10.202`) and RHEL 9 DataStage Engine (`10.10.10.201`).
    - Updates local authentication defaults from `ident` to `md5`.
- **Firewall Rules:** Opens the PostgreSQL service port in the RHEL 9 system firewall via `firewall-cmd`.

### 3. Service Lifecycle & Default Security

- **Systemd Management:** Enables and starts the `postgresql` service.
- **Admin Password:** Sets the default password for the `postgres` administrative user.

### 4. Database Provisioning & Schema Restoration

- **Idempotent Check:** Queries system catalogs to verify whether the target `demo` database already exists.
- **Database Creation:** Provisions the empty `demo` database if it does not yet exist.
- **Backup Restoration:** Uses `pg_restore` to load schemas and data idempotently from the staging backup (`/home/itzuser/electromart_demo.backup`) under the `postgres` user context.
