# S3 Bucket Layout for Binary Repository and Ansible Response File Templates in TechZone Environment

Parent Page: ([Deployment Environment for MettleCI](DeploymentEnvironmentforMettleCI.md))

## S3 Bucket Layout & Binary Repository (`binaries/`)

In the TechZone environment, the S3 object storage bucket serves as the centralized binary repository. It contains the complete offline payload required to provision the RHEL 9 server tier, the Windows client tier, and the entire DevOps toolchain without requiring external internet downloads during execution.

During the initial Windows bootstrap sequence (`ds_silent_install_cli.ps1`) and subsequent Ansible plays, target nodes pull down installation media, license files, packages, and authentication keys directly from this bucket using the AWS CLI.

### 1. Root `binaries/` Directory (Core Infrastructure & Toolchain)

| S3 Object Key | Size | Target Node | Component Description & Role |
| --- | --- | --- | --- |
| `IS_V11716_Linux_x86_multi.tar.gz` | 7.4 GiB | RHEL 9 | **IBM Information Server Media:** Core Linux payload for the Engine, Services, and Repository tiers. |
| `IS_V11.7.1.6_WINDOWS_CLIENT.zip` | 2.6 GiB | Windows | **Windows Client Media:** Extracts to deploy DataStage Designer, Director, and `istools`. |
| `IS_V11716.bundle_spec_file_mult.zip` | 4.2 MiB | RHEL 9 | **Bundle Specification File:** Required by the IBM installer for suite component resolution. |
| `v11.5.8_linuxx64_server_dec.tar.gz` | 1.7 GiB | RHEL 9 | **Db2 Server Media:** IBM Db2 v11.5.8 base installation media for the Information Server repository database. |
| `jenkins-2.462.3-1.1.noarch.rpm` | 88.8 MiB | RHEL 9 | **Jenkins Server:** Local RPM installed on the RHEL 9 node for pipeline orchestration. |
| `gitea-1.27.0-linux-amd64` | 119.9 MiB | RHEL 9 | **Gitea Binary:** Standalone Go binary for the Git version control server. |
| `gitea-runner-3.3.2-linux-amd64` | 17.8 MiB | RHEL 9 | **Gitea Runner:** Binary for executing Gitea Actions CI/CD workflows. |
| `cpd-cli-linux-EE-14.3.0.tgz``cpd-cli-linux-EE-14.3.1.tgz` | \~210 MiB | RHEL 9 | **Cloud Pak for Data CLI:** Administrator utilities for interacting with IBM CPD environments. |
| `pgadmin4-9.17-x64.exe` | 221.3 MiB | Windows | **pgAdmin 4 Installer:** Windows utility for managing backend PostgreSQL databases. |
| `WinSCP-6.5.6-Setup.exe` | 11.7 MiB | Windows | **WinSCP Installer:** Secure file transfer client for the Windows TechZone node. |
| `ssh/CommKey.pub` | N/A | Windows | **Public SSH Key:** Administrative public key registered to Windows OpenSSH for secure remote management. |

### 2. MettleCI & Custom Software (`binaries/dm_software/`)

| S3 Object Key | Size | Target Node | Component Description & Role |
| --- | --- | --- | --- |
| `dm-mettleci-workbench-2.1-2070.noarch.rpm` | 61.0 MiB | RHEL 9 | **MettleCI Workbench RPM:** Core server-side engine installed on RHEL 9. |
| `dm-mettleci-command-shell-1.1-298.noarch.rpm` | 211.8 MiB | RHEL 9 | **MettleCI Command Shell RPM:** CLI toolkit for automated MettleCI orchestration. |
| `dm-unittest-harness-1.3-543.noarch.rpm` | 12.7 MiB | RHEL 9 | **MettleCI Unit Test Harness RPM:** Execution framework for DataStage unit tests. |
| `OpenJDK11U-jdk_x64_linux_hotspot_11.0.32_9.tar.gz` | 186.6 MiB | RHEL 9 | **Java 11 Runtime:** Extracted to `/usr/lib/jvm` to power MettleCI services. |
| `dm-compliance-rules-325.zip` | 391.1 KiB | RHEL 9 | **Compliance Rules:** Zip package containing governance rules extracted to Gitea. |
| `mettleci-repo-template-102.zip` | 104.0 KiB | RHEL 9 | **Repository Template:** Base template used to initialize Gitea project repositories. |
| `MCI_Setup.exe` | 64.6 KiB | Windows | **MettleCI Windows Setup:** Bootstraps MettleCI Designer UI hooks on the Windows client. |
| `mettleci.lic` | 1.0 KiB | Both | **MettleCI License File:** Shared licensing key for Workbench and CLI features. |
| `config.yml.cpy` | 868 Bytes | RHEL 9 | **Workbench Config Template:** Base configuration injected into `/opt/dm/mci/config.yml`. |
| `SourceData.zip` | 4.0 MiB | RHEL 9 | **Test Data Archive:** Staged source datasets extracted into DataStage project directories. |
| `electromart_demo.backup` | 6.2 MiB | RHEL 9 | [**Electromart Demo**](https://datamigrators.atlassian.net/wiki/spaces/MCI/pages/2986934317/ElectroMart+Infrastructure)** Backup Data:** Pre-populated project backup/database dump for the environment. |
| `jenkins_devops_techzone.isx` | 1.1 MiB | Windows | **DataStage ISX Payload:** Serialized project import handled via `istools` on Windows. |

### 3. Ansible Response File Templates (`templates/`)

While the heavy binaries are pulled from S3, the orchestration logic relies on a suite of response file templates stored natively within the Git repository structure under the `templates/` directory.

The RHEL 9 server files utilize Jinja2 (`.j2`) templating, allowing the master Ansible playbook to dynamically inject environment variables (like `ibm_password`, dynamic IPs, and installation paths) at runtime to generate the final `.rsp` configuration payloads.

| Template File | Execution Node | Component Description & Role |
| --- | --- | --- |
| `db2_server.rsp.j2` | RHEL 9 | **Db2 Silent Installation:** Dynamically configures the Db2 v11.5.8 instance creation, defining instance owners (`db2inst1`), fenced users, and TCP/IP port bindings. |
| `repo.rsp.j2` | RHEL 9 | **IS Repository Tier:** Drives the silent configuration of the IBM Information Server metadata repository (XMETA) and staging databases within Db2. |
| `services.rsp.j2` | RHEL 9 | **IS Services Tier:** Orchestrates the installation of the Information Server Services tier, including WebSphere Application Server (Liberty profile) and internal registry bindings. |
| `engine.rsp.j2` | RHEL 9 | **IS Engine Tier:** Configures the core DataStage execution engine, node agents, and project directory structures. |
| `ds_client.rsp` | Windows | **Windows Client Installer:** The static silent response file used by `ds_silent_install_cli.ps1` to bypass GUI prompts during the DataStage Client setup. |
