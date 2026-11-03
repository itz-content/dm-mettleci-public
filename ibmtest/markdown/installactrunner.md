# Deploying Gitea Actions Runner with Podman on RHEL 9

**Parent Page:** ([Master Deployment Pipeline](MasterDeploymentPipeline.md))

## Install Gitea Runner (`install_act_runner.yml`)

This playbook deploys and configures the Gitea Actions runner (`act_runner`) on RHEL 9. It sets up Podman as a container runtime replacement for Docker, registers the runner against the local Gitea instance using dynamically generated tokens, and configures a persistent systemd daemon.

### 1. Podman & Docker Socket Emulation

- **Container Engine:** Installs `podman` via DNF.
- **Socket Service:** Enables and starts `podman.socket` to provide a Docker-compatible API socket.
- **Compatibility Symlink:** Creates a symlink from `/run/podman/podman.sock` to `/var/run/docker.sock` so `act_runner` can seamlessly orchestrate containerized pipeline jobs.

### 2. Binary Deployment & Runner Registration

- **Binary Placement:** Copies the staged runner binary to `/usr/local/bin/act_runner` with executable permissions (`0755`).
- **Configuration Directory:** Provisions `/etc/act_runner` for runner state and configuration files.
- **Token Generation:** Programmatically generates a secure registration token from the local Gitea instance using the Gitea CLI (`actions generate-runner-token`).
- **Non-Interactive Registration:** Automatically registers the runner against `http://localhost:53000` using the generated token, creating the local `.runner` configuration metadata file.

### 3. Systemd Service Integration & Lifecycle

- **Service Definition:** Deploys a managed `act_runner.service` systemd unit file configured to depend on network, `podman.socket`, and `gitea.service`, targeting the Docker host socket environment variable (`DOCKER_HOST=unix:///run/podman/podman.sock`).
- **Service Startup:** Reloads the systemd daemon, enables, and starts the `act_runner` daemon service.
