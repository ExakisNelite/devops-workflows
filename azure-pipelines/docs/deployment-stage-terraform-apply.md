# deployment-stage-terraform-apply : Terraform Plan & Apply (Stage)

---------------------------

## Description

This Azure DevOps **stage template** provides a complete Terraform deployment stage chain. It orchestrates two stages:

1. **Generate Terraform Plan** stage: runs [job-terraform-plan](./job-terraform-plan.md) to validate the code, run the Checkov security analysis, generate the execution plan and publish it as an artifact.
2. **Apply** stage: runs [deployment-job-terraform-apply](./deployment-job-terraform-apply.md) to apply the plan on the target Azure DevOps environment (approval gates configured in the Azure DevOps portal). This stage runs only if the plan stage succeeded.

The plan and apply phases can use **different tfstate files** (`nameTfstatePlan` / `nameTfstateApply`), which supports scenarios where the plan is generated against a separate state.

## Parameters

| Name                  | Type   | Default             | Description                                                              |
|-----------------------|--------|---------------------|--------------------------------------------------------------------------|
| planStageName         | string | GeneratePlan        | Name of the plan stage.                                                  |
| applyStageName        | string | Apply               | Name of the apply stage.                                                 |
| dependsOnStages       | object | []                  | Stages this plan stage depends on.                                       |
| planJobName           | string | plan_apply          | Name of the plan job.                                                    |
| planJobDisplayName    | string | Terraform Plan Apply| Display name of the plan job.                                            |
| planArtifactName      | string | tfplan-apply        | Name of the artifact used to publish the plan.                           |
| planTerraformFileName | string | apply.tfplan        | Name of the Terraform plan file to generate.                             |
| applyDeploymentName   | string | terraform_apply     | Name of the apply deployment job.                                        |
| applyJobDisplayName   | string | Terraform Apply     | Display name of the apply deployment job.                                |
| applyArtifactName     | string | tfplan-apply        | Name of the artifact read by the apply job (must match planArtifactName).|
| applyTerraformFileName| string | apply.tfplan        | Name of the plan file applied by the apply job.                          |
| terraformVersion      | string | 1.14.7              | The version of Terraform to use.                                         |
| serviceConnection     | string | (required)          | Azure service connection used to authenticate against ARM.               |
| rgNameTfstate         | string | (required)          | Resource group name of the storage account where the state is stored.    |
| storageNameTfstate    | string | (required)          | Storage account name where the state is stored.                          |
| containerNameTfstate  | string | (required)          | Container name on the storage account where the state is stored.         |
| nameTfstatePlan       | string | (required)          | Terraform state file name for the plan phase.                            |
| nameTfstateApply      | string | (required)          | Terraform state file name for the apply phase.                           |
| workingDirectory      | string | ./                  | Directory containing the Terraform files, relative to the repository root.|
| checkovConfigDirectory| string | ./configuration     | Directory containing the Checkov configuration files.                    |
| variablesFile         | string | ''                  | Path to a tfvars file used with the `-var-file` flag.                    |
| additionalVariables   | string | ''                  | Terraform variables written to a terraform.tfvars file if provided.      |
| environment           | string | recette             | Azure DevOps environment name with approval gates configured.            |

## Usage example

```yaml
stages:
  - template: azure-pipelines/templates/deployment-stage-terraform-apply.yml
    parameters:
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstatePlan: myapp-plan.tfstate
      nameTfstateApply: myapp.tfstate
      workingDirectory: ./terraform
      environment: recette

  # Chain another environment, gated by the previous one
  - template: azure-pipelines/templates/deployment-stage-terraform-apply.yml
    parameters:
      planStageName: GeneratePlanProduction
      applyStageName: ApplyProduction
      dependsOnStages: [Apply]
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstatePlan: myapp-plan-prd.tfstate
      nameTfstateApply: myapp-prd.tfstate
      workingDirectory: ./terraform
      environment: production
```
