# job-terraform-validate-iac-modules : Terraform Build & Check for IaC Modules

---------------------------

## Description

This Azure DevOps job template is a variant of [job-terraform-validate](./job-terraform-validate.md) dedicated to validating Terraform **modules** (IaC modules repositories). Unlike `job-terraform-validate`, it runs on the module's own test directory and does not require the `iac-modules` repository resource.

It performs the same build & check sequence: firewall opening on the tfstate storage account, Terraform install, tfstate container/lease management, Terraform init/validate, TFLint, Terraform plan, and plan summary publication.

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

## Usage example

```yaml
jobs:
  - template: azure-pipelines/templates/job-terraform-validate-iac-modules.yml
    parameters:
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstate: mymodule-tests.tfstate
      workingDirectory: ./tests
```

> **Note**: This template is usually not called directly. Prefer the [jobs-terraform-checks](./jobs-terraform-checks.md) template, which chains this validation job with Super-Linter and terraform-docs jobs.
