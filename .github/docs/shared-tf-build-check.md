# shared-tf-build-check : 🛠️ Build & Check Terraform

---------------------------

## Description

This GitHub Actions workflow automates the build and validation process for Terraform infrastructure code. It listens for workflow calls, allowing manual triggers or integration with other workflows. The workflow includes the following jobs:

1. **Checkov**: Perform Checkov security analysis
   1. **Checkout Working Directory**: Fetches the latest changes from the repository.
   2. **Login with Azure CLI**: Authenticates with Azure CLI using the provided credentials.
   3. **Open Resources Firewall**: Opens firewall rules for specified resources.
   4. **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   5. **Init the connection to meilleureux GitHub Organization**: Initializes the connection to the meilleureux GitHub Organization to use Terraform modules.
   6. **Setup Terraform**: Sets up Terraform with the specified version.
   7. **Check if container exists, otherwise create it**: Ensures the Terraform state container exists in Azure Storage.
   8. **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   9. **Build Variables File**: Creates terraform.tfvars file from provided variables if available.
   10. **Format terraform.tfvars**: Formats the terraform.tfvars file using terraform fmt.
   11. **Terraform Validate**: Validates the Terraform configuration files.
   12. **Terraform Plan**: Generates an execution plan for Terraform changes.
       - Supports both input variable files and dynamically created terraform.tfvars.
       - Automatically detects and uses terraform.tfvars if it exists.
       - Captures plan output for later analysis.
   13. **Terraform Show**: Displays a detailed report of the Terraform execution plan.
       - Converts the plan output to JSON format for Checkov analysis.
   14. **Checkov Exception**: Generates exceptions for Checkov security checks.
   15. **Checkov Security Check**: Performs a Checkov security check, see [devops-action-terraform-checkov](https://github.com/ExakisNelite/devops-action-terraform-checkov) for more information.
   16. **Close Resources Firewall**: Closes firewall rules for specified resources.
2. **SuperLinter**: Perform super-linter checks
   1. **Checkout Working Directory**: Fetches the latest changes from the repository.
   2. **Call Composite Action Superlinter**: Perform super-linter checks, see [devops-action-terraform-superlinter](https://github.com/ExakisNelite/devops-action-terraform-superlinter) for more information.
3. **Terraform Fmt**: Perform Formatting Checks
   1. **Checkout Working Directory**: Fetches the latest changes from the repository.
   2. **Call Composite Action Terraform Fmt**: Perform formatting checks, see [devops-action-terraform-fmt](https://github.com/ExakisNelite/devops-action-terraform-fmt) for more information.
4. **Terraform Docs**: Generate documentation
   1. **Checkout Working Directory**: Fetches the latest changes from the repository.
   2. **Call Terraform Docs Action**: Generate documentation using Terraform Docs.

## Input Parameters

| Name                              | Type    | Default                  | Description                                                                 |
|-----------------------------------|---------|--------------------------|-----------------------------------------------------------------------------|
| REPOSITORY                        | string  | current repository       | The name of the repository where the Terraform files are located.          |
| TERRAFORM_VERSION                 | string  | 1.6.4                    | The version of Terraform to use for the build process.                     |
| WORKING_DIRECTORY                 | string  | .                        | The directory containing the Terraform files relative to the repository root. |
| TESTS_DIRECTORY                   | string  | .                        | The directory containing the Terraform tests files relative to the repository root. |
| VARIABLES_FILE                    | string  | ''                       | The path to the tfvars file. If provided, will be used with the -var-file flag. |
| CHECKOV_CONFIG_DIRECTORY          | string  | ./.github/configuration  | The directory containing the Checkov configuration files.                  |
| TARGET_BRANCH                     | string  | main                     | Target branch to checkout.                                                 |
| DEFAULT_BRANCH                    | string  | (required)               | Default branch of the repository.                                          |
| ENVIRONMENT                       | string  | integration              | The target environment for the Terraform deployment.                       |
| RG_NAME_TFSTATE                   | string  |                          | Resource Group Name of the Storage Account where the State is stored.      |
| STORAGE_NAME_TFSTATE              | string  |                          | Storage Account Name where the State is stored.                            |
| CONTAINER_NAME_TFSTATE            | string  |                          | Container Name on the Storage Account where the State is stored.           |
| NAME_TFSTATE                      | string  |                          | Terraform State file name.                                                 |
| USE_OIDC                          | boolean | true                     | Use OIDC for the backend.                                                  |
| SHOULD_GENERATE_MODULES_DOCUMENTATION | boolean | false                  | Should generate the documentation for the Terraform modules.               |
| USE_TERRASCAN                     | boolean | false                    | Should use Terrascan to check the Terraform code.                          |
| LINTER_VALIDATE_ALL_CODEBASE      | boolean | true                     | Should validate the whole codebase.                                        |
| LINTER_VALIDATE_CHECKOV           | boolean | true                     | Should validate the Checkov rules.                                         |
| LINTER_VALIDATE_MARKDOWN          | boolean | true                     | Should validate the Markdown files.                                        |
| LINTER_VALIDATE_NATURAL_LANGUAGE  | boolean | true                     | Should validate the Natural Language files.                                |
| LINTER_VALIDATE_JSON              | boolean | true                     | Should validate the JSON files.                                            |
| TERRAFORM_TFLINT_CONFIG_FILE      | string  | .tflint.hcl              | Filename for tfLint configuration (e.g., .tflint.hcl).                     |
| SHOULD_EXECUTE_LINTER             | boolean | false                    | Should execute the linter check control.                                   |
| TERRAFORM_DOCS_CONFIG_FILE        | string  | .terraform-docs.yaml     | Filename for Terraform Docs configuration (e.g., .terraform-docs.yaml).    |

## Secrets Parameters

| Name                              | Type    | Description                                                  |
|-----------------------------------|---------|--------------------------------------------------------------|
| CLIENT_ID                         | string  | Azure Service Principal Client ID.                          |
| SUBSCRIPTION_ID                   | string  | Azure Subscription ID.                                       |
| TENANT_ID                         | string  | Azure Tenant ID.                                             |
| UNIVERSAL_GH_APP_ID_CODE          | string  | GitHub App ID.                                               |
| UNIVERSAL_GH_APP_PRIVATE_KEY_CODE | string  | GitHub App Private Key.                                      |
| VARIABLES                         | string  | Terraform variables. Will be written to terraform.tfvars if provided. |

## Variable Handling

The workflow supports two methods for providing Terraform variables:

1. **Using VARIABLES_FILE input**: Specify a path to an existing .tfvars file that will be used with the `-var-file` flag.
2. **Using VARIABLES secret**: Provide variables directly that will be written to a terraform.tfvars file in the working directory.

If both methods are used:

- Both the specified VARIABLES_FILE and the generated terraform.tfvars will be included in the terraform plan command.
- The terraform.tfvars file takes precedence over the specified VARIABLES_FILE if there are conflicting variable definitions.

Example of VARIABLES format:

```text
variable1 = "value1"
variable2 = 123
variable3 = true
```

## Actions Included

- **actions/checkout@v5**: Action to checkout the working directory, fetching the latest changes from the repository.

- **azure/login@v2**: Action to authenticate with Azure CLI using provided credentials.

- **ExakisNelite/devops-action-firewall@latest**: Actions to manage firewall rules for specified resources.

- **ExakisNelite/devops-action-terraform-checkov@latest**: Action to perform Checkov security analysis on the Terraform code.

- **ExakisNelite/devops-action-terraform-superlinter@latest**: Action to perform linter format checks on the Terraform code.

- **ExakisNelite/devops-action-terraform-fmt@latest**: Action to perform format checks on the Terraform code.

- **terraform-docs/gh-actions@v1.3.0**: Action to generate documentation for the Terraform code.

- **getsentry/action-github-app-token@v3.0.0**: Action to generate a token for authenticating with GitHub App.

- **hashicorp/setup-terraform@v3.1.2**: Action to set up Terraform with the specified version.

- Other Terraform-related actions such as `terraform init`, `terraform validate`, `terraform plan`, `terraform show`.

## GitHub App Permissions

The GitHub App used in this workflow requires the following permissions to function correctly:

| Permission         | Access Level | Description                                                                 |
|--------------------|--------------|-----------------------------------------------------------------------------|
| `id-token`         | `write`      | Required for authentication using OpenID Connect (OIDC).                   |
| `actions`          | `write`      | Allows the workflow to trigger and manage GitHub Actions.                  |
| `contents`         | `write`      | Enables access to repository contents for reading and writing.             |
| `pull-requests`    | `write`      | Required to create, update, or comment on pull requests.                   |
| `security-events`  | `write`      | Allows reporting and managing security events, such as Checkov findings.   |

Ensure that the GitHub App is configured with these permissions to avoid any issues during workflow execution.

## How to use this workflow

To use this reusable workflow in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  build-check:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check.yml@v0.1.7
    with:
      TERRAFORM_VERSION: '1.6.4'
      WORKING_DIRECTORY: './terraform'
      ENVIRONMENT: 'development'
      RG_NAME_TFSTATE: 'rg-terraform-states'
      STORAGE_NAME_TFSTATE: 'terraformstatesstorage'
      CONTAINER_NAME_TFSTATE: 'tfstates'
      NAME_TFSTATE: 'my-project.tfstate'
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
      VARIABLES: |
        environment = "development"
        location = "westeurope"
```

### Key considerations

1. Properly define parameters related to Terraform state storage in Azure
2. Provide required Azure credentials via secrets
3. Configure linting and validation parameters according to your code quality requirements

## Examples

### Using the workflow to check code of Terraform resources with a variables file

```yaml
name: Example Usage of shared-tf-build-check

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  build-and-check:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check.yml@latest
    with:
      WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
      TESTS_DIRECTORY: './<Folder containing the tests of the resources>/'
      CHECKOV_CONFIG_DIRECTORY: ./.github/configuration
      DEFAULT_BRANCH: 'main'
      RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State is stored>'
      STORAGE_NAME_TFSTATE: '<Storage Account Name where the State is stored>'
      CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State is stored>'
      NAME_TFSTATE: '<Terraform State file name>'
      VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
      LINTER_VALIDATE_ALL_CODEBASE: false
      LINTER_VALIDATE_CHECKOV: false
      LINTER_VALIDATE_MARKDOWN: false
      LINTER_VALIDATE_NATURAL_LANGUAGE: false
      LINTER_VALIDATE_JSON: false
      SHOULD_GENERATE_DOCUMENTATION: false
      SHOULD_EXECUTE_LINTER: false
      TARGET_BRANCH: ${{ github.ref_name }}
      EVENT_NAME: ${{ github.event_name }}
      TERRAFORM_VERSION: '1.10.5'
      TERRAFORM_DOCS_CONFIG_FILE: '.terraform-docs.yaml'
    secrets:
      CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
      SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
      TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Using the workflow to check code of Terraform resources passing variables

```yaml
name: Example Usage of shared-tf-build-check

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  build-and-check:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check.yml@latest
    with:
      WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
      TESTS_DIRECTORY: './<Folder containing the tests of the resources>/'
      CHECKOV_CONFIG_DIRECTORY: ./.github/configuration
      DEFAULT_BRANCH: 'main'
      RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State is stored>'
      STORAGE_NAME_TFSTATE: '<Storage Account Name where the State is stored>'
      CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State is stored>'
      NAME_TFSTATE: '<Terraform State file name>'
      LINTER_VALIDATE_ALL_CODEBASE: false
      LINTER_VALIDATE_CHECKOV: false
      LINTER_VALIDATE_MARKDOWN: false
      LINTER_VALIDATE_NATURAL_LANGUAGE: false
      LINTER_VALIDATE_JSON: false
      SHOULD_GENERATE_DOCUMENTATION: false
      SHOULD_EXECUTE_LINTER: false
      TARGET_BRANCH: ${{ github.ref_name }}
      EVENT_NAME: ${{ github.event_name }}
      TERRAFORM_VERSION: '1.10.5'
      TERRAFORM_DOCS_CONFIG_FILE: '.terraform-docs.yaml'
    secrets:
      CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
      SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
      TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
      VARIABLES: |
        variable1                = "\"${{ secrets.VARIABLE1 }}"\"
        variable2                = "\"${{ secrets.VARIABLE2 }}"\"
```

### Using both variable file and inline variables

```yaml
name: Example Usage of shared-tf-build-check with both variable methods

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  build-and-check:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check.yml@latest
    with:
      WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
      TESTS_DIRECTORY: './<Folder containing the tests of the resources>/'
      VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
      # Other parameters...
    secrets:
      # Other secrets...
      VARIABLES: |
        variable1                = "\"${{ secrets.VARIABLE1 }}"\"
        variable2                = "\"${{ secrets.VARIABLE2 }}"\"
```
