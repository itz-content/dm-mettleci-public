# End User Experience Videos (Quick Start)

**Parent Page:** ([Deployment Environment for MettleCI](DeploymentEnvironmentforMettleCI.md))

## Initial Access Instructions
From the MettleCI Education Collection, request the Beta1 Environment.  
[]
 <video width="100%" controls> 
  <source src="../images/vEnvironment Request.mp4" type="video/mp4"> 
</video> 
![Warning Message](./images/WarningMessage.jpeg)

## Environment Login

Open the environment. Login to the Workstation and establish SSH connetion to the server via WinSCP.  The WinSCP connection is not required, however it will make it easier to access files on the server should this become necessary during your exploration.  
[]
<video width="100%" controls> 
  <source src="../images/vEnvironment Login and WinSCP.mp4" type="video/mp4"> 
</video>

## Infrastructure Diagram

The infrastructure diagram illustrates the applications utilized as part of the MettleCI Education (BETA1) Environment.

![mci_education_infrastructure](./images/mci_education_infrastructure.jpeg)

### GITEA
User: itzuser Password: giteapwd

MettleCI uses Git repositories as the storage for a comprehensive library of compliance rules (Cmpliance) and as the centralized version control system and single source of truth for IBM DataStage project assets, in this case Jenkins_Devops (Electromart).  
*Note: Although GITEA is used in this environment for education purposes.  All the major Source Code Management (SCM) software/Code Hosting Platforms like GitHub, Bitbucket and Azure are supported.*  
[]
<video width="100%" controls> 
  <source src="../images/vGitea Login.mp4" type="video/mp4"> 
</video>

### POSTGRESQL
User: postgres Password: postgres

In our BETA1 enviornment PostgreSQL houses the source data used by the Jenkins_Devops (Electromart) Datastage project. PgAdmin4 is available in the BETA1 environment should you want to access the database directly.  Follow the video for connection procedure.  This is not a requirement.
[]
<video width="100%" controls> 
  <source src="../images/vPostgres Login.mp4" type="video/mp4"> 
</video>

### WORKBENCH
User: isadmin Password: 9BaAMKZjzmTiDcJtRb

You've seen where our demo data lives in PostgreSQL and where our code resides in Gitea. Next, we step into MettleCI Workbench—the tool that actually connects your DataStage jobs to those Git repositories. The following video walks through logging into Workbench for the first time and verifying how our repositories are mapped to our development projects.
[]
<video width="100%" controls> 
  <source src="../images/vWorkbench Login.mp4" type="video/mp4"> 
</video>

## The Developer Workflow: MettleCI in DataStage

With the backend infrastructure and repositories in place, it is time to look at the daily developer experience. The true power of MettleCI is that it embeds these DevOps practices directly into the tools you already use. The following sequence walks through a standard development cycle entirely from within IBM DataStage Designer.

### DataStage Designer Login

First, we step into the developer's workspace. This video demonstrates how to log into the IBM DataStage Designer and locate the MettleCI interface. You will see how MettleCI's controls are seamlessly integrated directly alongside your standard DataStage canvas.
[]
<video width="100%" controls> 
  <source src="../images/vDatastage Designer Login.mp4" type="video/mp4"> 
</video>

### Checking Compliance

Before saving code to the repository, it needs to meet organizational standards. This video shows how to run MettleCI's automated compliance checks against your DataStage job. It highlights how developers can instantly identify design violations, naming convention errors, or performance bottlenecks without ever leaving the Designer.
[]
<video width="100%" controls> 
  <source src="../images/vCheck Compliance.mp4" type="video/mp4"> 
</video>

### Committing Assets to Git

Once your job is compliant and ready, it is time to save your work. Instead of relying on manual exports, this video walks through committing a DataStage asset directly to our Gitea repository using MettleCI. You will see how code is packaged, associated with a commit message, and safely versioned.
[]
<video width="100%" controls> 
  <source src="../images/vCommit Asset.mp4" type="video/mp4"> 
</video>

### Creating a Unit Test

A reliable automated pipeline requires robust testing. This next video in the sequence demonstrates how to quickly create a MettleCI Unit Test for your DataStage job. By capturing expected data inputs and outputs, you can ensure your code functions correctly and prevent future changes from breaking existing logic.
[]
<video width="100%" controls> 
  <source src="../images/vCreate New Unit Test.mp4" type="video/mp4"> 
</video>

### Catching Regressions: Unit Test Failures

Even small changes to code can have unintended consequences. This video demonstrates what happens when a developer alters a derivation within a Transformer stage, which inadvertently changes the job's data output. When this modified job is run against our previously established Unit Test Spec, the test catches the discrepancy and immediately fails. You will see how MettleCI's diagnostic output clearly highlights the exact differences in the data, allowing developers to quickly identify and fix regressions before they leave the development environment.
[]
<video width="100%" controls> 
  <source src="../images/vUnit Test Fail.mp4" type="video/mp4"> 
</video>
