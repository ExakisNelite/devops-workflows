# deployment-job-terraform-destroy : Terraform Destroy (Deployment Job)

---------------------------

## Description

This Azure DevOps **deployment job** template applies a Terraform **destroy plan** previously generated and published as an artifact by [job-terraform-plan](./job-terraform-plan.md) (with `destroyMode: true`). As a deployment job, it targets an **Azure DevOps environment** — approval gates are configured on the environment in the Azure DevOps portal, not in YAML.

It follows the same sequence as [deployment-job-terraform-apply](./deployment-job-terraform-apply.md): firewall opening, Terraform install, plan artifact download, Terraform init, apply of the destroy plan, and firewall closing (even on failure).

## Parameters

| Name                  | Type   | Default           | Description                                                                    |
|-----------------------|--------|-------------------|--------------------------------------------------------------------------------|
| deploymentName        | string | terraform_deploy  | Name of the deployment job.                                                    |
| deploymentDisplayName | string | Terraform Deploy  | Display name of the deployment job.                                            |
| artifactName          | string | drop              | Name of the artifact containing the Terraform destroy plan file.               |
| terraformPlanFileName | string | (required)        | Name of the Terraform destroy plan file to apply (e.g., destroy.tfplan).       |
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
  - template: azure-pipelines/templates/deployment-job-terraform-destroy.yml
    parameters:
      artifactName: tfplan-destroy
      terraformPlanFileName: destroy.tfplan
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstate: myapp.tfstate
      environment: recette
```

> **Note**: This template is usually not called directly. Prefer the stage template [deployment-stage-terraform-destroy](./deployment-stage-terraform-destroy.md), which chains the destroy plan job with this deployment job.
