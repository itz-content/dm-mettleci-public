# Automating DataStage Project Import and MettleCI Client Integration on Windows

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Import DataStage Project (`import_datastage_project.yml`)

This playbook executes on the remote Windows TechZone target node via SSH. It automates the import of serialized DataStage asset archives (`.isx`), installs MettleCI client components, and dynamically patches Windows user registry entries to bind MettleCI custom tool menu extensions.

### 1. SSL Trust & Asset Import (`istools`)

- **Certificate Trust:** Executes `UpdateSignerCerts.bat` silently from the ASBNode binary path to trust the remote Information Server domain certificate (`10.10.10.201:59445`).
- **ISX Archive Import:** Runs `istool.bat import` to load the `jenkins_devops_techzone.isx` package directly into the target DataStage server project space (`server-1/Jenkins_Devops`), replacing existing assets with the `-replace` flag. Log output is captured and outputted to the console for verification.

### 2. MettleCI Windows Client Integration

- **Silent Installer:** Executes the MettleCI client package (`MCI_Setup.exe`) silently (`/S`) to deploy custom menu items onto the Windows machine.
- **UUID Discovery:** Automatically queries the Windows Registry (`HKCU:\Software\IBM\InformationServer\DataStage Client`) using PowerShell to discover the unique DataStage Client installation GUID.

### 3. Registry Custom Menu Patching

Updates the user registry keys under the discovered client UUID to wire up MettleCI web hooks directly inside the DataStage Designer UI tools menu (`[http://10.10.10.201:58081](http://10.10.10.201:58081)`):

- `Menu#0`**:** Bound to `/projects/%ProjectName/test-cases/%JobName` (Unit Testing).
- `Menu#1`**:** Bound to `/projects/%ProjectName/commits/create?assets=%JobName` (Version Control / Commits).
- `Menu#2`**:** Bound to `/projects/%ProjectName/compliance/create?asset=%JobName` (Compliance Checks).
