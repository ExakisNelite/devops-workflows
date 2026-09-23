# jobs-terraform-checks : Terraform Checks (CI)

---------------------------

## Description

This Azure DevOps jobs template is the entry point for the continuous integration of Terraform code, typically used for IaC modules repositories. It orchestrates the following jobs:

1. **Checkov & Terraform Plan**: Runs [job-terraform-validate](./job-terraform-validate.md) against the tests directory — Terraform init/validate/plan with Checkov security analysis.
2. **Super-Linter** (optional, `shouldExecuteLinter`): Runs Super-Linter in a Docker container with fine-grained validation toggles (Checkov, Markdown, Natural Language, JSON, YAML).
3. **Terraform Docs** (optional, `shouldGenerateDocumentation`): Generates the Terraform modules documentation using terraform-docs and the configuration file specified by `terraformDocsConfigFile`.

## Parameters

| Name                          | Type    | Default              | Description                                                                 |
|-------------------------------|---------|----------------------|-----------------------------------------------------------------------------|
| jobName                       | string  | (required)           | Base name used to build the job names.                                      |
| displayName                   | string  | (required)           | Display name suffix used in job display names.                              |
| azureServiceConnection        | string  | (required)           | Azure service connection used to authenticate against ARM.                  |
| subscriptionId                | string  | (required)           | Azure subscription ID.                                                      |
| tenantId                      | string  | (required)           | Azure tenant ID.                                                            |
| workingDirectory              | string  | .                    | Directory containing the Terraform module files.                            |
| testsDirectory                | string  | ./tests              | Directory containing the Terraform tests files.                             |
| checkovConfigDirectory        | string  | ./configuration      | Directory containing the Checkov configuration files.                       |
| rgNameTfstate                 | string  | (required)           | Resource group name of the storage account where the state is stored.       |
| storageNameTfstate            | string  | (required)           | Storage account name where the state is stored.                             |
| containerNameTfstate          | string  | (required)           | Container name on the storage account where the state is stored.            |
| nameTfstate                   | string  | (required)           | Terraform state file name.                                                  |
| variablesFile                 | string  | ''                   | Path to a tfvars file used with the `-var-file` flag.                       |
| terraformVersion              | string  | 1.14.7               | The version of Terraform to use.                                            |
| defaultBranch                 | string  | main                 | Default branch of the repository.                                           |
| shouldExecuteLinter           | boolean | false                | Execute the Super-Linter check job.                                         |
| shouldGenerateDocumentation   | boolean | false                | Generate the Terraform modules documentation.                               |
| linterValidateAllCodebase     | boolean | false                | Super-Linter: validate the whole codebase.                                  |
| linterValidateCheckov         | boolean | false                | Super-Linter: validate the Checkov rules.                                   |
| linterValidateMarkdown        | boolean | false                | Super-Linter: validate the Markdown files.                                  |
| linterValidateNaturalLanguage | boolean | false                | Super-Linter: validate natural language.                                    |
| linterValidateJson            | boolean | false                | Super-Linter: validate the JSON files.                                      |
| linterValidateYaml            | boolean | false                | Super-Linter: validate the YAML files.                                      |
| terraformDocsConfigFile       | string  | .terraform-docs.yaml | Filename for terraform-docs configuration.                                  |
| environment                   | string  | integration-modules  | Target environment name (used for display and naming).                      |

## Usage example

```yaml
stages:
  - stage: Checks
    jobs:
      - template: azure-pipelines/templates/jobs-terraform-checks.yml
        parameters:
          jobName: mymodule
          displayName: My Module
          azureServiceConnection: my-service-connection
          subscriptionId: $(AZURE_SUBSCRIPTION_ID)
          tenantId: $(AZURE_TENANT_ID)
          rgNameTfstate: rg-terraform-state
          storageNameTfstate: sttfstate
          containerNameTfstate: tfstate
          nameTfstate: mymodule-tests.tfstate
          shouldExecuteLinter: true
          linterValidateMarkdown: true
          linterValidateYaml: true
          shouldGenerateDocumentation: true
```
