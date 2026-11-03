# Master Deployment Pipeline for IBM Information Server with MettleCI DevOps Toolchain

**Parent Page:** ([Deployment Pipeline Architecture Overview](DeploymentPipelineArchitectureOverview.md))

## Master Deployment Pipeline (`main.yml`)

This workflow orchestrates the end-to-end automated deployment of IBM Information Server (11.7) alongside a complete MettleCI DevOps toolchain.

### Phase 1: Environment Preparation

- [**check\_prereqs.yml**](prereqs.md): Validates that target infrastructure meets master deployment requirements.
- [**tune\_os.yml**](tuneos.md): Optimizes the Linux operating system kernel and system limits for IBM data workloads.
- [**transfer\_binaries\_S3.yml**](transferbinaries.md): Retrieves necessary installation media and binaries from an S3 bucket to the local execution environment.

### Phase 2: IBM Information Server Core

- [**install\_db2.yml**](installdb2.md): Executes the standalone installation of the IBM Db2 repository database.
- [**install\_iis\_tiers.yml**](installiis.md): Installs the core IBM Information Server engine, services, and repository tiers.

### Phase 3: DataStage Project Configuration

- [**create\_datastage\_project.yml**](createdsproject.md): Provisions the initial DataStage project workspace on the Linux engine.
- [**import\_datastage\_project.yml**](importdsproject.md): Dynamically loads the Windows client, executes ISX imports, and patches Windows-specific MettleCI registry settings.

### Phase 4: DevOps & MettleCI Infrastructure

- [**install\_postgresql.yml**](installpostgresql.md): Provisions the backend database required for Gitea and MettleCI.
- [**install\_gitea.yml**](installgitea.md): Installs the local Git repository hosting service.
- [**install\_act\_runner.yml**](installactrunner.md): Configures the Gitea action runners for CI/CD pipeline execution.
- [**setup\_mettleci\_repos.yml**](setupmcirepos.md): Initializes the specific Git repositories required for MettleCI version control.
- [**install\_mettleci.yml**](installmci.md): Deploys the core MettleCI application and integrates it with DataStage.
- [**install\_jenkins.yml**](installjenkins.md): Installs Jenkins as the primary orchestration engine for DataStage CI/CD pipelines.
