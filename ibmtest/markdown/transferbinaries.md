# Transfer Binaries Playbook for IBM Cloud Object Storage and Installation Setup

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Transfer Binaries (`transfer_binaries_S3.yml`)

This playbook retrieves all required enterprise installation media, software packages, and security keys from an IBM Cloud Object Storage (S3-compatible) repository and unpacks them into their respective staging locations.

### 1. Tooling & Staging Initialization

- **AWS CLI Provisioning:** Verifies if the `aws` CLI binary is installed on the host. If missing, it downloads, extracts, and installs AWS CLI v2 into `/tmp`.
- **Target Directory Prep:** Ensures the core installation staging directory (`/opt/IBM/InformationServer`) exists with `root:dstage` ownership and permissive access (`0777`).
- **User Workspace:** Enforces existence and ownership of `/home/itzuser`.

### 2. Binary Retrieval via S3

Connects to the S3 bucket (`dm-mettleci-public`) using custom endpoint `[https://s3.us.cloud-object-storage.appdomain.cloud](https://s3.us.cloud-object-storage.appdomain.cloud)` with secret masking (`no_log: true`) to pull:

- **IBM Information Server Suite:** `IS_V11716_Linux_x86_multi.tar.gz` and `IS_V11716.bundle_spec_file_mult.zip` into `/opt/IBM/InformationServer`.
- **Db2 Database:** `v11.5.8_linuxx64_server_dec.tar.gz` into `/opt/IBM/InformationServer`.
- **DevOps Toolchain:**
    - `dm_software` RPMs directory synced recursively to `/home/itzuser/`.
    - Gitea (`gitea-1.27.0-linux-amd64`) binary to `/home/itzuser/`.
    - Gitea Action Runner (`gitea-runner-3.3.2-linux-amd64`) binary to `/home/itzuser/`.
    - Jenkins RPM (`jenkins-2.462.3-1.1.noarch.rpm`) staged as `/home/itzuser/jenkins-local.rpm`.
- **SSH Key Material:** Retrieves private deployment key `CommKey` into `/home/itzuser/.ssh/` with strict `0600` permissions.

### 3. Extraction & Workspace Setup

- **Main Suite Extraction:** Unpacks the primary Information Server archive directly within `/opt/IBM/InformationServer`.
- **Db2 Extraction:** Extracts the Db2 server archive into an isolated subdirectory: `/opt/IBM/InformationServer/db2_extracted`.
- **Bundle Spec File:** Extracts the spec file zip directly into the `is-suite` subfolder.
- **File Permissions & Verification:**
    - Recursively enforces `root:dstage` (`0777`) across the extracted `is-suite` directory.
    - Verifies that critical installation entry points (`setup` and `image.properties`) exist before downstream plays execute.
    - Sets execution permissions (`0755`) on the Gitea and action runner binaries.

### 4. Disk Optimization & Cleanup

- Purges the large downloaded tarballs and zip archives (`IS_V11716_Linux_x86_multi.tar.gz`, `IS_V11716.bundle_spec_file_mult.zip`, and `v11.5.8_linuxx64_server_dec.tar.gz`) from the staging path to prevent root volume space exhaustion.
