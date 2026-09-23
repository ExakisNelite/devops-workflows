# job-terraform-plan : Terraform Plan

---------------------------

## Description

This Azure DevOps job template generates a Terraform execution plan (or a destroy plan when `destroyMode` is `true`) and publishes it as a pipeline artifact for a later apply/destroy deployment job. It includes the following steps:

1. **Checkout Repository**: Fetches the latest changes from the repository.
2. **Open Firewall**: Opens the firewall on the tfstate storage account (via [steps-azure-manage-firewall-open](./steps-azure-manage-firewall-open.md)).
3. **Wait for Storage Data Plane Readiness**: Confirms the storage data plane is reachable before proceeding.
4. **Install Terraform**: Installs the specified Terraform version.
5. **Ensure TFState Blob Container Exists**: Creates the tfstate container if it does not exist.
6. **Break TFState Blob Lease**: Breaks the blob lease if the state file is locked.
7. **Authenticate Git for Terraform Modules**: Configures Git authentication with `$(System.AccessToken)` to fetch Terraform modules from Azure DevOps Repos.
8. **Terraform Init**: Initializes the Terraform working directory with the Azure backend (Entra ID authentication).
9. **Build terraform.tfvars**: Creates a terraform.tfvars file from `additionalVariables` if provided.
10. **Terraform Validate**: Validates the Terraform configuration files.
11. **Terraform Plan**: Generates the execution plan (`-out=<terraformPlanFileName>`), or a destroy plan when `destroyMode` is `true`.
12. **Terraform Show (JSON)**: Converts the plan to JSON format for Checkov analysis.
13. **Generate Human-Readable Plan Output**: Converts the plan to text for the pipeline summary.
14. **Checkov Security Check**: Runs Checkov on the plan JSON with optional skip rules read from `<checkovConfigDirectory>/checkov-skip`, and publishes the results as JUnit test results.
15. **Publish Plan Artifact**: Publishes the plan file as a pipeline artifact for the apply/destroy deployment job.
16. **Close Firewall**: Removes the firewall rule created at the beginning of the job.

## Parameters

| Name                   | Type    | Default                | Description                                                                 |
|------------------------|---------|------------------------|-----------------------------------------------------------------------------|
| jobName                | string  | terraform_plan         | Name of the job.                                                            |
| jobDisplayName         | string  | Terraform Plan         | Display name of the job.                                                    |
| artifactName           | string  | drop                   | Name of the artifact used to publish the plan.                              |
| terraformPlanFileName  | string  | (required)             | Name of the Terraform plan file to generate (e.g., apply.tfplan).           |
| terraformVersion       | string  | 1.14.7                 | The version of Terraform to use.                                            |
| firewallRuleName       | string  | AzureDevOpsAgent       | Name of the firewall rule created on the tfstate storage account.           |
| serviceConnection      | string  | (required)             | Azure service connection used to authenticate against ARM.                  |
| rgNameTfstate          | string  | (required)             | Resource group name of the storage account where the state is stored.       |
| storageNameTfstate     | string  | (required)             | Storage account name where the state is stored.                             |
| containerNameTfstate   | string  | (required)             | Container name on the storage account where the state is stored.            |
| nameTfstate            | string  | (required)             | Terraform state file name.                                                  |
| workingDirectory       | string  | .                      | Directory containing the Terraform files, relative to the repository root.  |
| checkovConfigDirectory | string  | ./configuration        | Directory containing the Checkov configuration files (checkov-skip).        |
| variablesFile          | string  | ''                     | Path to a tfvars file. If provided, used with the `-var-file` flag.         |
| additionalVariables    | string  | ''                     | Terraform variables written to a terraform.tfvars file if provided.         |
| environment            | string  | integration            | Target environment name (used for display and naming).                      |
| publishPlanSummary     | boolean | true                   | Publish the Terraform plan output to the pipeline summary.                  |
| destroyMode            | boolean | false                  | Generate a destroy plan (`terraform plan -destroy`) instead of a plan.      |

## Prerequisites

- A repository resource named `iac-modules` must be declared in the consuming pipeline.
- The service connection must have data plane access (Entra ID) on the tfstate storage account and permission to modify its network rules.

## Usage example

```yaml
jobs:
  - template: azure-pipelines/templates/job-terraform-plan.yml
    parameters:
      terraformPlanFileName: apply.tfplan
      artifactName: tfplan-apply
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstate: myapp.tfstate
      environment: recette
```

> **Note**: This template is usually not called directly. Prefer the stage templates [deployment-stage-terraform-apply](./deployment-stage-terraform-apply.md) or [deployment-stage-terraform-destroy](./deployment-stage-terraform-destroy.md), which chain the plan with the corresponding deployment job and its approval gates.
