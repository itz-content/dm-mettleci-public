# IBM Information Server Deployment Pipeline Architecture Overview: vm\_map\_string and Bootstrap Initialization

**Parent Page:** ([Deployment Environment for MettleCI](DeploymentEnvironmentforMettleCI.md))

## Architecture Overview: `vm_map_string` & Pipeline Initialization

This document outlines the foundational architecture of the automated IBM Information Server 11.7.1.6 deployment pipeline across RHEL 9 and Windows TechZone targets.

At the very forefront of this architecture is `vm_map_string`, which governs the ephemeral cloud provisioning, environment mapping, and initial operating system bootstrapping before any configuration management playbooks execute.

### 1. The Core Role of `vm_map_string`

`vm_map_string` serves as the top-level blueprint and configuration mapping mechanism for the IBM TechZone environment. It defines:

- **Infrastructure Topology:** Provisions the dual-node architecture consisting of the primary RHEL 9 node (`10.10.10.201`) and the Windows TechZone target node (`10.10.10.202`).
- **Environment Variables & Secrets:** Injects critical baseline variables, such as administrative passwords (`ibm_password`), domain bindings, and networking configurations.
- **Cloud-Init / User Data Injection:** Automatically passes bootstrap payloads into the newly spawned virtual machines on first boot.

### 2. [The Windows Bootstrap Sequence]

([Windows Client Bootstrap Script](WindowsClientBootstrapScript.md)) (`ds_silent_install_cli.ps1`)

Because the Windows TechZone target spins up as a clean, unconfigured OS instance, it relies entirely on `vm_map_string` to trigger its initial software provisioning:

1. **Cloud-Init Trigger:** As part of the environment spawn defined in `vm_map_string`, the bootstrap routine invokes `ds_silent_install_cli.ps1` natively on the Windows node.
2. **Silent Client Provisioning:** The PowerShell script executes a silent installation of the IBM DataStage Client and CLI framework (`istools`), completely bypassing interactive GUI prompts.
3. **Staging Preparation:** It lays down required binaries, configuration files, and directory paths (`C:\is_temp`) required for subsequent remote automation.

### 3. Handoff to the [Ansible Master Pipeline]

([Master Deployment Pipeline](MasterDeploymentPipeline.md)) (`main.yml`)

Once `vm_map_string` and its underlying bootstrap scripts have successfully initialized the OS layers:

- **Inventory Integration:** The master Ansible orchestrator dynamically registers the RHEL 9 localhost and adds the provisioned Windows target (`10.10.10.202`) via the `add_host` module, utilizing secure SSH connectivity (`ansible_connection: ssh`, `ansible_shell_type: powershell`) authenticated through private keys (`CommKey`).
- **Execution Phase Transition:** With the raw binaries and OS prerequisites established by the bootstrap layer, Ansible takes over to run the sequential playbook phases:
    - **Phase 1-2:** RHEL 9 Server, Db2, and IIS tier provisioning (`10.10.10.201`).
    - **Phase 3:** DataStage project creation and Windows-side `istools` asset imports (`jenkins_devops_techzone.isx`).
    - **Phase 4:** DevOps toolchain deployment (PostgreSQL, Gitea, `act_runner`, Jenkins, and MettleCI integration).
