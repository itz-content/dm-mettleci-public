# Local RPM Installation and Configuration of Jenkins on RHEL 9

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install Jenkins (`install_jenkins.yml`)

This playbook handles the local RPM installation of Jenkins on RHEL 9, configures systemd overrides to assign a custom port and bypass the initial web setup wizard, and ensures the service is enabled and running.

### 1. Local RPM Installation

- **Package Deployment:** Installs Jenkins using the pre-staged local RPM file (`/home/itzuser/jenkins-local.rpm`) via DNF, disabling GPG signature checks for the offline lab environment.

### 2. Systemd Override Configuration

- **Override Directory:** Provisions the systemd service override directory (`/etc/systemd/system/jenkins.service.d`).
- **Environment Injection:** Writes the `override.conf` configuration file to:
    - Bypass the interactive setup wizard programmatically (`JAVA_OPTS=-Djenkins.install.runSetupWizard=false`).
    - Bind Jenkins to the designated custom port (`JENKINS_PORT=58082`).

### 3. Service Lifecycle Management

- **Systemd Reload & Startup:** Automatically reloads the systemd daemon when configuration changes occur, then starts or restarts the `jenkins` service while ensuring it is enabled for automatic boot persistence.
