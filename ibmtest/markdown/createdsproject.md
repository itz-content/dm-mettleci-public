# Automating DataStage Project Creation and MettleCI Unit Testing Configuration

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Create DataStage Project (`create_datastage_project.yml`)

This playbook automates the creation of the core DataStage project workspace (`Jenkins_Devops`), provisions its directory hierarchy, populates raw data assets from staged zip files, and injects the MettleCI Unit Testing parameter configurations.

### 1. Project Provisioning via `dsadmin`

- **Workspace Creation:** Sources the DataStage engine environment (`./dsenv`) and executes `dsadmin` to connect to the Information Server domain and provision the `Jenkins_Devops (Electromart)` project.
- **Idempotency Handling:** Safely registers execution outcomes, ignoring errors if the project workspace already exists to ensure repeatable playbook runs without failure. Credentials are protected using `no_log: true`.

### 2. Directory Structure & File Staging

- **Directory Provisioning:** Creates isolated project data and test directories under the DataStage project tree with standard `dsadm:dstage` (`0755`) ownership:
    - `/opt/IBM/InformationServer/Server/Projects/Jenkins_Devops/data/electromart/dataset`
    - `/opt/IBM/InformationServer/Server/Projects/Jenkins_Devops/data/electromart/file`
    - `/opt/IBM/InformationServer/Server/Projects/Jenkins_Devops/data/electromart/report`
    - `/opt/IBM/InformationServer/Server/Projects/Jenkins_Devops/testdata`
- **Asset Extraction:** Unpacks `/home/itzuser/SourceData.zip`, dropping Mac-specific metadata (`__MACOSX`, `.DS_Store`) while splitting test data and main source files into their target directories.
- **File Renaming & Normalization:** Copies and standardizes raw staging files to clean target names expected by downstream pipelines (e.g., mapping `StgCustomer_20K.csv` to `StgCustomer.csv`).
- **Permissions Lockdown:** Recursively enforces `dsadm:dstage` ownership across all newly extracted asset paths.

### 3. MettleCI Unit Testing Configuration

- **Parameter Injection:** Modifies the `DSParams` files for both the `Jenkins_Devops` project and the global `Template` directory using `lineinfile`.
- **Configuration Binding:** Injects the `DM_ENABLE_UNIT_TESTING` parameter definition beneath the `EnvVarDefns` anchor to enable MettleCI interception and unit testing capabilities across DataStage jobs.
