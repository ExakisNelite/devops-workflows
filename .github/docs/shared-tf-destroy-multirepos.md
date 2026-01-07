# shared-tf-destroy-multirepos : 💀 Destroy Terraform with variables file in a specific repository

----------------

## Description

This shared workflow is designed to destroy Terraform-managed infrastructure across multiple repositories. It supports the use of variable files, integrates with Azure for state management, and provides options for manual approval and forced destruction. The workflow is highly configurable and can be reused in various scenarios.

## Permissions for GitHub App

The GitHub App used in this workflow requires the following permissions:

| Permission         | Access Level | Reason                                                                 |
|--------------------|--------------|------------------------------------------------------------------------|
| `id-token`         | `write`      | To authenticate with Azure using OIDC.                                |
| `actions`          | `write`      | To manage workflow artifacts and logs.                                |
| `contents`         | `write`      | To clone repositories and access files.                               |
| `pull-requests`    | `write`      | To interact with pull requests if needed.                             |
| `security-events`  | `write`      | To report security-related events.                                    |

Ensure that the GitHub App is configured with these permissions to avoid issues during workflow execution.

## Input Parameters

| Name                     | Description                                                                 | Required | Type    | Default       |
|--------------------------|-----------------------------------------------------------------------------|----------|---------|---------------|
| `TERRAFORM_VERSION`      | Version of Terraform to use                                                | No       | String  | `1.6.4`       |
| `WORKING_DIRECTORY`      | Directory where Terraform commands will be executed                        | No       | String  | `.`           |
| `TARGET_BRANCH`          | Target branch to checkout                                                  | No       | String  | `main`        |
| `ENVIRONMENT`            | Environment to deploy test on                                              | Yes      | String  |               |
| `RG_NAME_TFSTATE`        | Name of the Resource Group containing the Storage Account storing `.tfstate`| Yes      | String  |               |
| `STORAGE_NAME_TFSTATE`   | Name of the Storage Account storing `.tfstate`                             | Yes      | String  |               |
| `CONTAINER_NAME_TFSTATE` | Name of the Blob Container storing `.tfstate`                              | Yes      | String  |               |
| `NAME_TFSTATE`           | Name of the `.tfstate` file (e.g., `platform.tfstate`)                     | Yes      | String  |               |
| `USE_OIDC`               | Use OIDC for the backend                                                   | No       | Boolean | `true`        |
| `FORCE_DESTROY`          | Force destroy without manual approval                                      | No       | Boolean | `false`       |
| `EVENT_NAME`             | Name of the event that triggered the workflow                              | No       | String  | `push`        |
| `VARIABLES_ORGANIZATION` | Organization containing the variables repository                           | No       | String  | `''`          |
| `VARIABLES_REPOSITORY`   | Name of the variables repository                                            | No       | String  | `''`          |
| `VARIABLES_BRANCH`       | Branch of the variables repository                                         | No       | String  | `''`          |
| `VARIABLES_FILE`         | Path to the variables file                                                 | No       | String  | `''`          |
| `RG_NAME_RESOURCES_TO_OPEN` | Name of the Resource Group containing resources to open in the firewall | No       | String  | `''`          |
| `OPEN_STORAGE_ACCOUNT_FIREWALL` | Open firewall for Storage Account                                    | No       | Boolean | `false`       |
| `OPEN_AZURE_SQL_DATABASE_FIREWALL` | Open firewall for Azure SQL Database                             | No       | Boolean | `false`       |
| `OPEN_AZURE_APPSERVICE_FIREWALL` | Open firewall for Azure App Service                                | No       | Boolean | `false`       |
| `OPEN_AZURE_FUNCTIONAPP_FIREWALL` | Open firewall for Azure Function App                              | No       | Boolean | `false`       |
| `OPEN_KEY_VAULT_FIREWALL` | Open firewall for Key Vault                                                | No       | Boolean | `false`       |
| `OPEN_ACR_FIREWALL` | Open firewall for Azure Container Registry                                     | No       | Boolean | `false`       |
| `OPEN_APPCONFIGURATION_FIREWALL` | Open firewall for Azure App Configuration                          | No       | Boolean | `false`       |

## Secrets Parameters

| Name                          | Description                                   | Required |
|-------------------------------|-----------------------------------------------|----------|
| `CLIENT_ID`                   | Azure Service Principal Client ID            | Yes      |
| `SUBSCRIPTION_ID`             | Azure Subscription ID                        | Yes      |
| `TENANT_ID`                   | Azure Tenant ID                              | Yes      |
| `UNIVERSAL_GH_APP_ID_CODE`    | GitHub App ID                                | Yes      |
| `UNIVERSAL_GH_APP_PRIVATE_KEY_CODE` | GitHub App Private Key                  | Yes      |
| `VARIABLES`                   | Terraform variables. Will be written to terraform.tfvars if provided. | No       |
| `VARIABLES_REPOSITORY_TOKEN`  | Token for the Terraform variables repository | No       |

## Variable Handling

The workflow supports three methods for providing Terraform variables:

1. **Using VARIABLES_FILE input**: Specify a path to an existing .tfvars file that will be used with the `-var-file` flag.
2. **Using VARIABLES secret**: Provide variables directly that will be written to a terraform.tfvars file in the working directory.
3. **Using variables from a separate repository**: Configure the `VARIABLES_ORGANIZATION`, `VARIABLES_REPOSITORY`, `VARIABLES_BRANCH`, and `VARIABLES_FILE` inputs to fetch variables from another repository.

If multiple methods are used:

- All variable sources will be included in the terraform plan command.
- The terraform.tfvars file takes precedence, followed by the specified VARIABLES_FILE, then the repository variables file.

Example of VARIABLES format:

```text
variable1 = "value1"
variable2 = 123
variable3 = true
```

## Actions Included

1. **Set Artifact Plan Name**: Generates a unique name for the Terraform plan artifact.
2. **Terraform Init, Validate, and Plan**: Initializes Terraform, validates configurations, and generates a destroy plan.
3. **Manual Approval and Terraform Destroy**: Optionally waits for manual approval before applying the destroy plan.
4. **Azure CLI Login**: Authenticates with Azure for state management.
5. **Firewall Management**: Opens and closes firewalls for secure access to resources.
6. **Artifact Management**: Uploads and downloads Terraform plan artifacts.

## Example

```yaml
name: Example Usage of shared-tf-destroy-multirepos

on:
  workflow_dispatch:
    inputs:
      ENVIRONMENT:
        description: 'Environment to destroy'
        required: true
        type: string

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  destroy:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-tf-destroy-multirepos.yml@latest
    with:
      ENVIRONMENT: ${{ inputs.ENVIRONMENT }}
      RG_NAME_TFSTATE: 'my-resource-group'
      STORAGE_NAME_TFSTATE: 'my-storage-account'
      CONTAINER_NAME_TFSTATE: 'my-container'
      NAME_TFSTATE: 'platform.tfstate'
      # Example with variables from another repository
      VARIABLES_ORGANIZATION: 'myorg'
      VARIABLES_REPOSITORY: 'terraform-variables'
      VARIABLES_BRANCH: 'main'
      VARIABLES_FILE: 'environments/production.tfvars'
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.GH_APP_ID }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.GH_APP_PRIVATE_KEY }}
      VARIABLES: |
        environment = "production"
        region = "westeurope"
```

### Using inline variables

```yaml
jobs:
  destroy:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-tf-destroy-multirepos.yml@latest
    with:
      # Other parameters...
    secrets:
      # Other secrets...
      VARIABLES: |
        variable1 = "\"${{ secrets.VARIABLE1 }}"\"
        variable2 = "\"${{ secrets.VARIABLE2 }}"\"
```

### With firewall management for Azure resources

```yaml
jobs:
  destroy:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-tf-destroy-multirepos.yml@latest
    with:
      # Other parameters...
      RG_NAME_RESOURCES_TO_OPEN: 'my-azure-resources-rg'
      OPEN_STORAGE_ACCOUNT_FIREWALL: true
      OPEN_KEY_VAULT_FIREWALL: true
      OPEN_AZURE_APPSERVICE_FIREWALL: true
    secrets:
      # Secrets...
```

## How to use this workflow

This workflow allows for the destruction of Terraform infrastructure using variable files stored in a separate repository from the infrastructure code. To use it in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  destroy-multirepo:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-tf-destroy-multirepos.yml@v0.1.7
    with:
      TERRAFORM_VERSION: '1.6.4'
      WORKING_DIRECTORY: './terraform'
      ENVIRONMENT: 'development'
      RG_NAME_TFSTATE: 'rg-terraform-states'
      STORAGE_NAME_TFSTATE: 'terraformstatesstorage'
      CONTAINER_NAME_TFSTATE: 'tfstates'
      NAME_TFSTATE: 'my-project.tfstate'
      VARIABLES_ORGANIZATION: 'meilleurtaux'
      VARIABLES_REPOSITORY: 'project-variables'
      VARIABLES_BRANCH: 'main'
      VARIABLES_FILE: 'dev/terraform.tfvars'
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Key considerations

1. This workflow is similar to `shared-tf-destroy` but with the ability to retrieve variable files from a separate GitHub repository
2. The parameters `VARIABLES_ORGANIZATION`, `VARIABLES_REPOSITORY`, `VARIABLES_BRANCH`, and `VARIABLES_FILE` are used to specify the location of the Terraform variable file
3. By default, a manual approval step is required before resource destruction, unless `FORCE_DESTROY` is set to `true`
4. Use this workflow with caution, especially in production or pre-production environments
