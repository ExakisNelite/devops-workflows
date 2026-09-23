# deployment-stage-terraform-destroy : Terraform Plan & Destroy (Stage)

---------------------------

## Description

This Azure DevOps **stage template** provides a complete Terraform destroy chain. It orchestrates two stages:

1. **Generate Terraform Plan** stage: runs [job-terraform-plan](./job-terraform-plan.md) with `destroyMode: true` to generate a destroy execution plan and publish it as an artifact.
2. **Destroy** stage: runs [deployment-job-terraform-destroy](./deployment-job-terraform-destroy.md) to apply the destroy plan on the target Azure DevOps environment (approval gates configured in the Azure DevOps portal). This stage runs only if the plan stage succeeded.

The plan and destroy phases can use **different tfstate files** (`nameTfstatePlan` / `nameTfstateDestroy`).

## Parameters

| Name                    | Type   | Default                | Description                                                                |
|-------------------------|--------|------------------------|----------------------------------------------------------------------------|
| planStageName           | string | GeneratePlan           | Name of the plan stage.                                                    |
| destroyStageName        | string | Destroy                | Name of the destroy stage.                                                 |
| dependsOnStages         | object | []                     | Stages this plan stage depends on.                                         |
| planJobName             | string | plan_destroy           | Name of the plan job.                                                      |
| planJobDisplayName      | string | Terraform Plan Destroy | Display name of the plan job.                                              |
| planArtifactName        | string | tfplan-destroy         | Name of the artifact used to publish the destroy plan.                     |
| planTerraformFileName   | string | destroy.tfplan         | Name of the Terraform destroy plan file to generate.                       |
| destroyDeploymentName   | string | terraform_destroy      | Name of the destroy deployment job.                                        |
| destroyJobDisplayName   | string | Terraform Destroy      | Display name of the destroy deployment job.                                |
| destroyArtifactName     | string | tfplan-destroy         | Name of the artifact read by the destroy job (must match planArtifactName).|
| terraformVersion        | string | 1.14.7                 | The version of Terraform to use.                                           |
| serviceConnection       | string | (required)             | Azure service connection used to authenticate against ARM.                 |
| rgNameTfstate           | string | (required)             | Resource group name of the storage account where the state is stored.      |
| storageNameTfstate      | string | (required)             | Storage account name where the state is stored.                            |
| containerNameTfstate    | string | (required)             | Container name on the storage account where the state is stored.           |
| nameTfstatePlan         | string | (required)             | Terraform state file name for the plan phase.                              |
| nameTfstateDestroy      | string | (required)             | Terraform state file name for the destroy phase.                           |
| workingDirectory        | string | ./                     | Directory containing the Terraform files, relative to the repository root. |
| checkovConfigDirectory  | string | ./configuration        | Directory containing the Checkov configuration files.                      |
| variablesFile           | string | ''                     | Path to a tfvars file used with the `-var-file` flag.                      |
| additionalVariables     | string | ''                     | Terraform variables written to a terraform.tfvars file if provided.        |
| environment             | string | recette                | Azure DevOps environment name with approval gates configured.              |

## Usage example

```yaml
stages:
  - template: azure-pipelines/templates/deployment-stage-terraform-destroy.yml
    parameters:
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstatePlan: myapp-plan.tfstate
      nameTfstateDestroy: myapp.tfstate
      workingDirectory: ./terraform
      environment: recette
```

> **Warning**: The destroy stage removes all resources managed by the Terraform configuration. Make sure approval gates are properly configured on the target Azure DevOps environment before using this template.
