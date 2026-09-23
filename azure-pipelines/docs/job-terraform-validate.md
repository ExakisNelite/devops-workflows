# job-terraform-validate : Terraform Build & Check

---------------------------

## Description

This Azure DevOps job template automates the build and validation process for Terraform infrastructure code. It includes the following steps:

1. **Checkout Repository**: Fetches the latest changes from the repository.
2. **Open Firewall**: Opens the firewall on the tfstate storage account to allow access from the Azure DevOps agent (via [steps-azure-manage-firewall-open](./steps-azure-manage-firewall-open.md)).
3. **Wait for Storage Data Plane Readiness**: Confirms the storage data plane is reachable before proceeding.
4. **Install Terraform**: Installs the specified Terraform version.
5. **Ensure TFState Blob Container Exists**: Creates the tfstate container if it does not exist.
6. **Break TFState Blob Lease**: Breaks the blob lease if the state file is locked.
7. **Authenticate Git for Terraform Modules**: Configures Git authentication with `$(System.AccessToken)` to fetch Terraform modules from Azure DevOps Repos.
8. **Terraform Init**: Initializes the Terraform working directory with the Azure backend (Entra ID authentication).
9. **Build terraform.tfvars**: Creates a terraform.tfvars file from `additionalVariables` if provided.
10. **Terraform Format Check**: Runs `terraform fmt -check -recursive`.
11. **Terraform Validate**: Validates the Terraform configuration files.
12. **TFLint**: Runs TFLint for Terraform linting.
13. **Terraform Plan**: Generates an execution plan (supports both `variablesFile` and generated terraform.tfvars).
14. **Terraform Show (JSON)**: Converts the plan to JSON format for Checkov analysis.
15. **Generate Human-Readable Plan Output**: Converts the plan to text for the pipeline summary.
16. **Publish Plan Summary**: Publishes the plan output to the pipeline summary and as an HTML artifact (when `publishPlanSummary` is `true`).
17. **Close Firewall**: Removes the firewall rule created at the beginning of the job.

## Parameters

| Name                   | Type    | Default                | Description                                                                 |
|------------------------|---------|------------------------|-----------------------------------------------------------------------------|
| jobName                | string  | terraform_build_check  | Name of the job.                                                            |
| jobDisplayName         | string  | Terraform Build & Check| Display name of the job.                                                    |
| artifactName           | string  | drop                   | Name of the artifact used to publish the plan.                              |
| terraformVersion       | string  | 1.14.7                 | The version of Terraform to use.                                            |
| firewallRuleName       | string  | AzureDevOpsAgent       | Name of the firewall rule created on the tfstate storage account.           |
| serviceConnection      | string  | (required)             | Azure service connection used to authenticate against ARM.                  |
| rgNameTfstate          | string  | (required)             | Resource group name of the storage account where the state is stored.       |
| storageNameTfstate     | string  | (required)             | Storage account name where the state is stored.                             |
| containerNameTfstate   | string  | (required)             | Container name on the storage account where the state is stored.            |
| nameTfstate            | string  | (required)             | Terraform state file name.                                                  |
| workingDirectory       | string  | .                      | Directory containing the Terraform files, relative to the repository root.  |
| checkovConfigDirectory | string  | ./configuration        | Directory containing the Checkov configuration files.                       |
| variablesFile          | string  | ''                     | Path to a tfvars file. If provided, used with the `-var-file` flag.         |
| additionalVariables    | string  | ''                     | Terraform variables written to a terraform.tfvars file if provided.         |
| environment            | string  | integration            | Target environment name (used for display and naming).                      |
| publishPlanSummary     | boolean | false                  | Publish the Terraform plan output to the pipeline summary.                  |

## Prerequisites

- A repository resource named `iac-modules` must be declared in the consuming pipeline (used to fetch Terraform modules from Azure DevOps Repos).
- The service connection must have data plane access (Entra ID) on the tfstate storage account.
- The service connection must be allowed to modify network rules on the tfstate storage account (firewall open/close).

## Usage example

```yaml
jobs:
  - template: azure-pipelines/templates/job-terraform-validate.yml
    parameters:
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstate: myapp.tfstate
      workingDirectory: ./terraform
      environment: integration
      publishPlanSummary: true
```
