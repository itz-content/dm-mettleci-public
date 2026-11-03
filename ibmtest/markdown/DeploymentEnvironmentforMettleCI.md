# Automated Deployment Environment for MettleCI and IBM Information Server with DevOps Integration

# 🏠 MettleCI & IBM Information Server Automated Deployment Environment

The primary objective of this project is to provide a turnkey, zero-touch sandbox for users to instantly experience **MettleCI**—a platform that brings true Continuous Integration, Continuous Delivery (CI/CD), and automated testing to IBM DataStage.

Rather than spending days manually configuring servers, this fully automated Infrastructure-as-Code (IaC) pipeline provisions a complete IBM Information Server 11.7.1.6 landscape and a modern DevOps toolchain on IBM TechZone. It makes the heavy infrastructure invisible so users can immediately evaluate MettleCI's developer and governance capabilities on day one.

## Core Architecture

([Deployment Pipeline Architecture Overview](DeploymentPipelineArchitectureOverview.md))

- **The MettleCI Experience:** ([End User Experience Videos](EndUserExperience.md))The architecture centers entirely around MettleCI. It automatically deploys the Workbench, Command Shell, and Unit Test Harness on RHEL 9, while seamlessly patching the Windows DataStage Designer registry to embed MettleCI integration hooks directly into the developer UI.
- **Pre-Populated Electromart Sandbox:** ([Electromart Infrastructure](ElectromartInfrastructure.md)) To ensure users don't face an empty workspace, the pipeline stages a fully functional `Jenkins_Devops` (Electromart) DataStage project and a supporting **PostgreSQL database**, providing a rich, ready-to-use ETL landscape for running compliance checks, unit tests, and pipelines.
- **Embedded DevOps Ecosystem:** The automated deployment of Gitea (version control) and Jenkins (CI/CD orchestration) establishes a complete software engineering loop. This toolchain supports MettleCI by demonstrating how Git commits, compliance rules, and automated builds work together in a real-world DataStage environment.
- **Automated Bootstrapping & Orchestration:** Driven by PowerShell (`ds_silent_install_cli.ps1`) on Windows and Ansible (`main.yml`) on Linux, the pipeline handles OS-level prerequisites, secure SSH key exchange, and idempotent service provisioning invisibly in the background.
- **Centralized S3 Payload Delivery**:([S3 Bucket Layout](S3BucketLayout.md)) A master S3 object bucket acts as the single source of truth, staging all heavy IBM media, Db2 databases, open-source toolchains, and proprietary MettleCI binaries (`dm_software`) for localized, high-speed deployment without external internet dependencies.
- **Dynamic Silent Provisioning:** Utilizing Jinja2-templated response files (`.rsp.j2`), the system dynamically injects environment-specific variables at runtime to silently install the Db2 Repository, IS Engine, Services tier, and Windows Client.
