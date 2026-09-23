# deployment-job-terraform-apply : Terraform Apply (Deployment Job)

---------------------------

## Description

This Azure DevOps **deployment job** template applies a Terraform plan previously generated and published as an artifact by [job-terraform-plan](./job-terraform-plan.md). As a deployment job, it targets an **Azure DevOps environment** — approval gates are configured on the environment in the Azure DevOps portal, not in YAML.

It includes the following steps:

1. **Checkout Repository**: Fetches the latest changes from the repository.
2. **Open Firewall**: Opens the firewall on the tfstate storage account (via [steps-azure-manage-firewall-open](./steps-azure-manage-firewall-open.md)).
3. **Install Terraform**: Installs the specified Terraform version.
4. **Download Plan Artifact**: Downloads the plan artifact produced by the plan job.
5. **Terraform Init**: Initializes the Terraform working directory with the Azure backend (Entra ID authentication).
6. **Terraform Apply**: Applies the downloaded plan file.
7. **Close Firewall**: Removes the firewall rule created at the beginning of the job (runs even on failure).

## Parameters

| Name                  | Type   | Default           | Description                                                                    |
|-----------------------|--------|-------------------|--------------------------------------------------------------------------------|
| deploymentName        | string | terraform_deploy  | Name of the deployment job.                                                    |
| deploymentDisplayName | string | Terraform Deploy  | Display name of the deployment job.                                            |
| artifactName          | string | drop              | Name of the artifact containing the Terraform plan file.                       |
| terraformPlanFileName | string | (required)        | Name of the Terraform plan file to apply (e.g., apply.tfplan).                 |
| terraformVersion      | string | 1.14.7            | The version of Terraform to use.                                               |
| firewallRuleName      | string | AzureDevOpsAgent  | Name of the firewall rule created on the tfstate storage account.              |
| serviceConnection     | string | (required)        | Azure service connection used to authenticate against ARM.                     |
| rgNameTfstate         | string | (required)        | Resource group name of the storage account where the state is stored.          |
| storageNameTfstate    | string | (required)        | Storage account name where the state is stored.                                |
| containerNameTfstate  | string | (required)        | Container name on the storage account where the state is stored.               |
| nameTfstate           | string | (required)        | Terraform state file name.                                                     |
| workingDirectory      | string | .                 | Directory containing the Terraform files, relative to the repository root.     |
| variablesFile         | string | ''                | Path to a tfvars file.                                                         |
| additionalVariables   | string | ''                | Terraform variables written to a terraform.tfvars file if provided.            |
| environment           | string | (required)        | Azure DevOps environment name with approval gates configured.                  |

## Prerequisites

- A repository resource named `iac-modules` must be declared in the consuming pipeline.
- The Azure DevOps environment referenced by `environment` must exist, with approval gates configured in the Azure DevOps portal.
- The service connection must have data plane access (Entra ID) on the tfstate storage account and permission to modify its network rules.

## Usage example

```yaml
jobs:
  - template: azure-pipelines/templates/deployment-job-terraform-apply.yml
    parameters:
      artifactName: tfplan-apply
      terraformPlanFileName: apply.tfplan
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstate: myapp.tfstate
      environment: recette
```

> **Note**: This template is usually not called directly. Prefer the stage template [deployment-stage-terraform-apply](./deployment-stage-terraform-apply.md), which chains the plan job with this deployment job.
