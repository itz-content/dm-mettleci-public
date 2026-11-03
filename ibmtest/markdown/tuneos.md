# Optimizing RHEL 9 for IBM Information Server 11\.7: User Limits, Kernel Tuning, and Stability Configurations

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Tune OS (`tune_os.yml`)

This playbook configures the Red Hat Enterprise Linux (RHEL 9) system parameters, kernel settings, and resource limits specifically optimized for an IBM Information Server 11.7 footprint operating with 32GB of RAM.

### 1. Linux User Limits (`ulimits`)

To prevent the DB2 database and DataStage engine from hitting resource exhaustion during heavy ETL workloads, the playbook injects a managed block into `/etc/security/limits.conf` for the necessary service accounts (`itzuser`, `dsadm`, `db2inst1`, `db2fenc1`, and `xmeta`).

Key limit adjustments include:

- **Open Files (**`nofile`**):** Increased to `65536` across all service accounts to support high-concurrency database connections and parallel file processing.
- **Processes (**`nproc`**):** Increased to `16384` to accommodate multi-node parallel DataStage jobs.
- **File Size (**`fsize`**):** Set to `unlimited` for the installer, DataStage engine, and DB2 instance owner to allow processing of massive flat files.
- **Data & Stack Size:** DB2 data size is set to `unlimited`, and the execution stack for DataStage/installer accounts is bumped to `10240`.

### 2. Kernel Tuning (`sysctl`)

The playbook creates a modular system configuration file at `/etc/sysctl.d/99-ibm-tuning.conf` and instantly reloads the kernel tree to apply the following parameters:

- **Shared Memory:** Scaled explicitly for a 32GB RAM allocation. Sets `kernel.shmmax` to \~28.9 GB and `kernel.shmall` to `7077888` pages.
- **Semaphores:** Tuned specifically to meet Db2 thresholds (`kernel.sem = 250 256000 32 1024`), ensuring adequate inter-process communication for database operations.
- **Virtual Memory & Swapping:** Reduces `vm.swappiness` to `10` (encouraging the OS to keep data in physical RAM rather than disk swap) and increases `vm.max_map_count` to `262144`.
- **Messaging:** Sets maximum message queue sizes (`kernel.msgmax` and `kernel.msgmnb`) to `65536`.

### 3. Global Environment & Application Routing Stability

- **Global Umask:** Enforces `umask 022` inside `/etc/profile`. This ensures that all files and directories created by IBM background processes inherit the correct baseline permissions, preventing "permission denied" errors between the engine tiers.
- **PAM Authentication Patch:** Edits `/etc/pam.d/other` to replace `pam_deny.so` with `pam_unix.so`, allowing legacy IBM GUI applications and routing services to authenticate successfully against the modern RHEL 9 Pluggable Authentication Module.
