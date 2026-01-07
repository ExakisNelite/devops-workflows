# shared-tf-build-check-deploy-multirepos : 🚀 Build, Check & Deploy Terraform with variables file in a specific repository

----------------

## Description

This shared workflow automates the process of building, checking, and deploying Terraform configurations across multiple repositories. It includes tasks such as linting, security checks, formatting, and deployment with support for variable files and Azure backend configurations. The workflow is designed to be reusable and configurable for different environments and repositories.

## Input Parameters

| Name                              | Description                                                                                     | Required | Default Value                  |
|-----------------------------------|-------------------------------------------------------------------------------------------------|----------|--------------------------------|
| `REPOSITORY`                      | The repository to target.                                                                      | No       | `${{ github.repository }}`    |
| `TERRAFORM_VERSION`               | The version of Terraform to use.                                                              | No       | `1.6.4`                        |
| `WORKING_DIRECTORY`               | The working directory for Terraform commands.                                                 | No       | `.`                            |
| `CHECKOV_CONFIG_DIRECTORY`        | Directory for Checkov configuration.                                                          | No       | `./.github/configuration`      |
| `TARGET_BRANCH`                   | Target branch to checkout.                                                                    | No       | `main`                         |
| `DEFAULT_BRANCH`                  | Default branch of the repository.                                                             | Yes      |                                |
| `ENVIRONMENT_CHECK`               | Environment for the check phase.                                                              | No       | `integration`                  |
| `ENVIRONMENT_DEPLOYMENT`          | Environment for the deployment phase.                                                         | No       | `recette`                      |
| `RG_NAME_TFSTATE`                 | Name of the Resource Group containing the Storage Account storing the `.tfstate` file.        | Yes      |                                |
| `STORAGE_NAME_TFSTATE`            | Name of the Storage Account storing the `.tfstate` file.                                      | Yes      |                                |
| `CONTAINER_NAME_TFSTATE`          | Name of the Blob Container storing the `.tfstate` file.                                       | Yes      |                                |
| `NAME_TFSTATE_BUILD_CHECK`        | Name of the `.tfstate` file for build and check operations.                                   | Yes      |                                |
| `NAME_TFSTATE_DEPLOY`             | Name of the `.tfstate` file for deployment operations.                                        | Yes      |                                |
| `USE_OIDC`                        | Use OIDC for the backend.                                                                     | No       | `true`                         |
| `SHOULD_GENERATE_MODULES_DOCUMENTATION` | Generate documentation for Terraform modules.                                              | No       | `false`                        |
| `USE_TERRASCAN`                   | Use Terrascan to check the Terraform code.                                                    | No       | `false`                        |
| `LINTER_VALIDATE_ALL_CODEBASE`    | Validate the whole codebase.                                                                  | No       | `true`                         |
| `LINTER_VALIDATE_CHECKOV`         | Validate Checkov rules.                                                                       | No       | `true`                         |
| `LINTER_VALIDATE_MARKDOWN`        | Validate Markdown files.                                                                      | No       | `true`                         |
| `LINTER_VALIDATE_NATURAL_LANGUAGE`| Validate natural language files.                                                              | No       | `true`                         |
| `LINTER_VALIDATE_JSON`            | Validate JSON files.                                                                          | No       | `true`                         |
| `TERRAFORM_TFLINT_CONFIG_FILE`    | Filename for `tfLint` configuration.                                                         | No       | `.tflint.hcl`                  |
| `SHOULD_EXECUTE_LINTER`           | Execute the linter check control.                                                             | No       | `false`                        |
| `FORCE_DESTROY`                   | Force destroy before plan.                                                                    | No       | `false`                        |
| `EVENT_NAME`                      | The name of the event that triggered the workflow.                                            | No       | `push`                         |
| `VARIABLES_ORGANIZATION`          | Organization for Terraform variables.                                                         | No       |                                |
| `VARIABLES_REPOSITORY`            | Repository for Terraform variables.                                                           | No       |                                |
| `VARIABLES_BRANCH`                | Branch for Terraform variables.                                                               | No       |                                |
| `VARIABLES_FILE`                  | Path to the Terraform variables file.                                                        | No       |                                |
| `RG_NAME_RESOURCES_TO_OPEN`       | Name of the Resource Group containing resources to open in the firewall.                      | No       | `''`                           |
| `OPEN_STORAGE_ACCOUNT_FIREWALL`   | Open firewall for Storage Account.                                                           | No       | `false`                        |
| `OPEN_AZURE_SQL_DATABASE_FIREWALL`| Open firewall for Azure SQL Database.                                                         | No       | `false`                        |
| `OPEN_AZURE_APPSERVICE_FIREWALL`  | Open firewall for Azure App Service.                                                         | No       | `false`                        |
| `OPEN_AZURE_FUNCTIONAPP_FIREWALL` | Open firewall for Azure Function App.                                                         | No       | `false`                        |
| `OPEN_KEY_VAULT_FIREWALL`         | Open firewall for Key Vault.                                                                 | No       | `false`                        |
| `OPEN_ACR_FIREWALL`               | Open firewall for Azure Container Registry.                                                  | No       | `false`                        |
| `OPEN_APPCONFIGURATION_FIREWALL`  | Open firewall for Azure App Configuration.                                                   | No       | `false`                        |

## Secrets Parameters

| Name                              | Description                                                                                     | Required |
|-----------------------------------|-------------------------------------------------------------------------------------------------|----------|
| `CLIENT_ID`                       | Azure Service Principal Client ID.                                                             | Yes      |
| `SUBSCRIPTION_ID`                 | Azure Subscription ID.                                                                         | Yes      |
| `TENANT_ID`                       | Azure Tenant ID.                                                                               | Yes      |
| `UNIVERSAL_GH_APP_ID_CODE`        | GitHub App ID.                                                                                 | Yes      |
| `UNIVERSAL_GH_APP_PRIVATE_KEY_CODE` | GitHub App Private Key.                                                                      | Yes      |
| `VARIABLES`                       | Terraform variables. Will be written to terraform.tfvars if provided.                          | No       |
| `VARIABLES_REPOSITORY_TOKEN`      | Token for the Terraform variables repository.                                                  | No       |

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

## Permissions for GitHub App

The GitHub App used in this workflow requires the following permissions:

| Permission                | Access Level | Reason                                                                 |
|---------------------------|--------------|------------------------------------------------------------------------|
| `id-token`                | `write`      | Required for authentication using OpenID Connect (OIDC).              |
| `actions`                 | `write`      | To retrieve and manage workflow runs and artifacts.                   |
| `contents`                | `write`      | To access repository files and make changes if needed.                |
| `pull_requests`           | `write`      | To interact with pull requests during workflow execution.             |
| `security-events`         | `write`      | To report security findings from Checkov and other tools.            |

Ensure that the GitHub App is installed with these permissions to avoid workflow execution issues.

## Actions Included

- **Terraform Checkov**: Performs security checks on Terraform plans using Checkov.
- **Super Linter**: Validates codebase with multiple linters.
- **Terraform FMT**: Formats Terraform code.
- **Terraform Init, Validate, and Plan**: Initializes, validates, and generates a plan for Terraform configurations.
- **Terraform Apply**: Applies the Terraform plan after manual approval.
- **Firewall Management**: Opens and closes Azure service firewalls for secure operations.

## How to use this workflow

This workflow is designed for scenarios where Terraform variable files are stored in a repository separate from the infrastructure code. To use it in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  multirepo-deploy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy-multirepos.yml@v0.1.7
    with:
      TERRAFORM_VERSION: '1.6.4'
      WORKING_DIRECTORY: './terraform'
      ENVIRONMENT_CHECK: 'integration'
      ENVIRONMENT_DEPLOYMENT: 'recette'
      RG_NAME_TFSTATE: 'rg-terraform-states'
      STORAGE_NAME_TFSTATE: 'terraformstatesstorage'
      CONTAINER_NAME_TFSTATE: 'tfstates'
      NAME_TFSTATE_BUILD_CHECK: 'my-project-int.tfstate'
      NAME_TFSTATE_DEPLOY: 'my-project-rec.tfstate'
      DEFAULT_BRANCH: 'main'
      VARIABLES_ORGANIZATION: 'ExakisNelite'
      VARIABLES_REPOSITORY: 'project-variables'
      VARIABLES_BRANCH: 'main'
      VARIABLES_FILE: 'recette/terraform.tfvars'
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Key considerations

1. This workflow is similar to `shared-tf-build-check-deploy` but with the ability to retrieve variable files from a separate GitHub repository
2. The parameters `VARIABLES_ORGANIZATION`, `VARIABLES_REPOSITORY`, `VARIABLES_BRANCH`, and `VARIABLES_FILE` are used to specify the location of the Terraform variable file
3. This approach is particularly useful when you want to:
   - Separate infrastructure code from configuration values
   - Manage access rights differently for code and variables
   - Maintain stricter governance structures for environment variables

## Example

```yaml
name: Example Usage of shared-tf-build-check-deploy-multirepos
on:
  workflow_dispatch:
    inputs:
      TARGET_BRANCH:
        description: 'Branch to deploy'
        required: true
        default: 'main'

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  call-shared-workflow:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy-multirepos.yml@latest
    with:
      TARGET_BRANCH: ${{ github.event.inputs.TARGET_BRANCH }}
      DEFAULT_BRANCH: 'main'
      RG_NAME_TFSTATE: 'my-resource-group'
      STORAGE_NAME_TFSTATE: 'my-storage-account'
      CONTAINER_NAME_TFSTATE: 'my-container'
      NAME_TFSTATE_BUILD_CHECK: 'platform.tfstate'
      NAME_TFSTATE_DEPLOY: 'platform.tfstate'
      # Example with variables from another repository
      VARIABLES_ORGANIZATION: 'myorg'
      VARIABLES_REPOSITORY: 'terraform-variables'
      VARIABLES_BRANCH: 'main'
      VARIABLES_FILE: 'environments/production.tfvars'
    secrets:
      CLIENT_ID: ${{ secrets.CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
      VARIABLES: |
        environment = "production"
        region = "westeurope"
      VARIABLES_REPOSITORY_TOKEN: ${{ secrets.GH_TOKEN }}
```

### Using both inline variables and a variables file

```yaml
jobs:
  call-shared-workflow:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy-multirepos.yml@latest
    with:
      # Other parameters...
      VARIABLES_FILE: './environments/dev.tfvars'
    secrets:
      # Other secrets...
      VARIABLES: |
        variable1 = "\"${{ secrets.VARIABLE1 }}"\"
        variable2 = "\"${{ secrets.VARIABLE2 }}"\"
```

### With firewall management for Azure resources

```yaml
jobs:
  call-shared-workflow:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy-multirepos.yml@latest
    with:
      # Other parameters...
      RG_NAME_RESOURCES_TO_OPEN: 'my-azure-resources-rg'
      OPEN_STORAGE_ACCOUNT_FIREWALL: true
      OPEN_KEY_VAULT_FIREWALL: true
      OPEN_AZURE_APPSERVICE_FIREWALL: true
    secrets:
      # Secrets...
```
