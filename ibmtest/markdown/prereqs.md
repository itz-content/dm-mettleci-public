# Prerequisites for Installing IBM Information Server 11\.7 on RHEL 9

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))


## Check Prerequisites (`check_prereqs.yml`)

**Parent Page:** \[Master Deployment Pipeline\]

This playbook executes the foundational environment validation and preparation required before installing IBM Information Server 11.7 on a modern Red Hat Enterprise Linux (RHEL 9) operating system. It enforces hardware minimums, installs legacy dependencies, and provisions the necessary service accounts.

### 1. Hardware & OS Gatekeepers

Before any modifications are made, the playbook verifies the environment can support the IBM workload:

- **Operating System:** Enforces **RHEL 9** as the target OS.
- **Compute Capacity:** Asserts a minimum of **2 vCPUs** and **12GB RAM** (11,600 MB).
- **Storage Capacity:** Asserts at least **60GB** of free disk space is available on the root (`/`) mount.

### 2. Legacy Package Support & Workarounds

Because IBM Information Server 11.7 relies on older system libraries, this playbook injects specific workarounds to make it compatible with RHEL 9:

- **System Utilities:** Installs required packages including `net-tools`, `ed`, `util-linux`, `unzip`, `bc`, and `nano`.
- `chkconfig`** Integration:** Safely handles the installation of `chkconfig` and recreates the legacy `/etc/init.d` directory structure if it was missing.
- `libXp`** Workaround:** Downloads and installs a legacy `libXp-1.0.2` RPM from the CentOS 7.9 vault, as this library was removed from RHEL 9 but is required by the IBM installer GUI/engine.
- **OpenSSL Compatibility:** Creates symlinks to map RHEL 9's OpenSSL 3 libraries (`libcrypto.so.3` / `libssl.so.3`) to the OpenSSL 1.0 filenames (`.so.10`) expected by IBM binaries.
- **PAM Patching:** Replaces `pam_deny.so` with `pam_unix.so` in `/etc/pam.d/other` to prevent authentication blocks during the installation process.

### 3. Java Environment Setup

- **SDK Installation:** Installs `java-1.8.0-openjdk-devel`.
- **Path Configuration:** Locates the Java 1.8 binary and uses the `alternatives` command line tool to enforce it as the system's default Java version.

### 4. Identity & Access Management

Provisions the standard isolated service accounts required by the Db2 and DataStage engines:

- **IBM Groups:** Creates `dstage`, `db2iadm1`, and `db2fadm1`.
- **IBM Users:**
    - `dsadm` (DataStage Administrator)
    - `db2inst1` (Db2 Instance Owner)
    - `db2fenc1` (Db2 Fenced User)
    - `xmeta` (Repository User)
    - `dsodb` (Operations Database User)
- **Automation Access:** Appends the Ansible connection user (`itzuser`) to the newly created IBM groups to ensure deployment scripts have sufficient permissions.
- **Profile Scrubbing:** Removes interactive `stty` commands from the `.bashrc` profiles of `db2inst1`, `db2fenc1`, and `dsadm` to prevent stdout corruption during automated remote shell executions.

### 5. Filesystem Preparation

- **Installation Directories:** Creates `/opt/IBM/InformationServer` and enforces `root:dstage` ownership with `0777` permissions.
- **Temporary Staging:**
    - Ensures the global `/tmp` directory retains standard `1777` permissions.
    - Creates an isolated `/opt/IBM/is_install_tmp` directory (`1777`) specifically for the IBM installation engine to prevent space exhaustion in the root `/tmp`.
