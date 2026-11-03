# Automating MettleCI Repository Setup and Gitea Integration

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Setup MettleCI Repositories (`setup_mettleci_repos.yml`)

This playbook automates the discovery, extraction, local Git initialization, Gitea remote provisioning, and code push for the core MettleCI repositories (`compliance`, `electromart`, and `jenkins-mci-shared-libraries`).

### 1. Dynamic Asset Discovery & Verification

- **Compliance Zip Discovery:** Dynamically locates the compliance rules archive (`dm-compliance-rules-*.zip`) in the source staging directory and asserts that exactly one matching file is present.
- **Template Zip Discovery:** Dynamically locates the MettleCI repository template archive (`mettleci-repo-template-*.zip`) and asserts that exactly one matching file is present.

### 2. Repository Staging & Structure Definition

- **Fact Mapping:** Defines the structured list of the three target repositories (`compliance`, `electromart`, and `jenkins-mci-shared-libraries`), mapping their respective zip packages and nested copy paths.
- **Directory Provisioning:** Creates isolated target paths under `/home/itzuser/LocalRepos` and temporary staging folders under `/tmp`.
- **Archive Extraction & Cleanup:** Unpacks the archives into the staging locations, copies the exact nested contents to the target directories, and cleans up the temporary staging trees.

### 3. Git Initialization & Local Commit

- **Sanitization:** Strips out any pre-existing nested `.git` folders extracted from the zip templates.
- **Local Repository Setup:** Initializes a fresh Git repository in each project path, configures local user credentials (`itzuser`), stages all extracted files, and creates an initial commit (`Initial commit: Extracted base files for [repository]`).

### 4. Gitea Integration & Remote Push

- **API Repository Creation:** Communicates with the Gitea REST API (`/api/v1/user/repos`) using basic authentication to provision private remote repositories for each project name, safely handling existing repository conflicts (`409`).
- **Remote Linking & Push:** Configures the remote origin URL embedding authentication credentials, renames the active branch to `main`, and pushes the local repositories upstream to Gitea.
