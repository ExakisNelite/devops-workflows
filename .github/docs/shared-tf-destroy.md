# shared-tf-destroy : 💀 Destroy Terraform

----------------

## Description

This GitHub Actions workflow automates the validation, and destruction of Terraform infrastructure resources. It can be triggered manually or through other workflows. The workflow includes the following jobs:

1. **Generate Artifact Plan Name**: Generates the artifact plan name.
   - **Set Artifact Plan Name**: Builds an artifact plan name from the Terraform state file name.
2. **Terraform Init, Validate & Plan**: Initializes Terraform modules, validates Terraform code, and builds a plan.
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Login with Azure CLI**: Authenticates with Azure CLI using provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHubOrganization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Check if container exists, otherwise create it**: Ensures the backend container exists in Azure Storage.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Build Variables File**: Creates terraform.tfvars file from provided variables if available.
   - **Format terraform.tfvars**: Formats the terraform.tfvars file using terraform fmt.
   - **Terraform Validate**: Validates the Terraform configuration files.
   - **Terraform Plan**: Generates a destructive plan for Terraform removals, with or without a variables file.
     - Supports both input variable files via the `VARIABLES_FILE` input and dynamically created terraform.tfvars via the `VARIABLES` secret.
     - Automatically detects and uses terraform.tfvars if it exists.
     - Adds a summary of plan changes to the workflow summary.
   - **Upload Resulting Terraform as Artifact**: Uploads the Terraform plan as an artifact.
   - **Close Resources Firewall**: Closes firewall rules for specified resources after execution.
3. **Terraform Approve & Apply**: Approves and applies Terraform destructive changes.
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Download Terraform Plan Artifact**: Downloads the previously generated Terraform plan artifact.
   - **Login with Azure CLI**: Authenticates with Azure CLI using provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHubOrganization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Terraform Destroy**: Applies Terraform destructive changes if approved.
   - **Close Resources Firewall**: Closes firewall rules for specified resources after execution.

## Input Parameters

| Name                        | Type    | Default       | Description                                                                 |
|-----------------------------|---------|---------------|-----------------------------------------------------------------------------|
| TERRAFORM_VERSION           | string  | 1.6.4         | The version of Terraform to use for deployment.                            |
| WORKING_DIRECTORY           | string  | .             | The directory containing the Terraform files relative to the repository root. |
| TARGET_BRANCH               | string  | main          | Target branch to checkout.                                                 |
| VARIABLES_FILE              | string  | ''            | The path to the tfvars file. If provided, will be used with the -var-file flag. |
| ENVIRONMENT                 | string  | (required)    | The environment to deploy the infrastructure (e.g., development, production). |
| RG_NAME_TFSTATE             | string  | (required)    | Resource Group Name of the Storage Account where the State is stored.      |
| STORAGE_NAME_TFSTATE        | string  | (required)    | Storage Account Name where the State is stored.                            |
| CONTAINER_NAME_TFSTATE      | string  | (required)    | Container Name on the Storage Account where the State is stored.           |
| NAME_TFSTATE                | string  | (required)    | Terraform State file name.                                                 |
| USE_OIDC                    | boolean | true          | Use OIDC for the backend.                                                  |
| FORCE_DESTROY               | boolean | false         | If set to true, the destruction will proceed without manual approval. |
| EVENT_NAME                  | string  | push          | The name of the event that triggered the workflow.                         |
| RG_NAME_RESOURCES_TO_OPEN   | string  | ''            | Name of the Resource Group containing resources to open in the firewall.   |
| OPEN_STORAGE_ACCOUNT_FIREWALL | boolean | false      | Open firewall for Storage Account.                                        |
| OPEN_AZURE_SQL_DATABASE_FIREWALL | boolean | false   | Open firewall for Azure SQL Database.                                     |
| OPEN_AZURE_APPSERVICE_FIREWALL | boolean | false    | Open firewall for Azure App Service.                                      |
| OPEN_AZURE_FUNCTIONAPP_FIREWALL | boolean | false   | Open firewall for Azure Function App.                                     |
| OPEN_KEY_VAULT_FIREWALL     | boolean | false         | Open firewall for Key Vault.                                              |
| OPEN_ACR_FIREWALL           | boolean | false         | Open firewall for Azure Container Registry.                               |
| OPEN_APPCONFIGURATION_FIREWALL | boolean | false    | Open firewall for Azure App Configuration.                                |

## Secrets Parameters

| Name                              | Type    | Description                                                              |
|-----------------------------------|---------|--------------------------------------------------------------------------|
| CLIENT_ID                         | string  | Azure Service Principal Client ID.                                       |
| SUBSCRIPTION_ID                   | string  | Azure Subscription ID.                                                   |
| TENANT_ID                         | string  | Azure Tenant ID.                                                         |
| UNIVERSAL_GH_APP_ID_CODE          | string  | GitHub App ID.                                                           |
| UNIVERSAL_GH_APP_PRIVATE_KEY_CODE | string  | GitHub App Private Key.                                                  |
| VARIABLES                         | string  | Terraform variables. Will be written to terraform.tfvars if provided.    |

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

## GitHub App Permissions

The GitHub App used in this workflow requires the following permissions:

| Permission         | Access Level | Reason                                                                 |
|---------------------|--------------|------------------------------------------------------------------------|
| Actions            | Read/Write   | To manage workflow runs and artifacts.                                |
| Contents           | Read/Write   | To fetch and update repository content.                               |
| Pull Requests      | Read/Write   | To interact with pull requests if needed.                             |
| Security Events    | Read/Write   | To access security-related events for the repository.                 |
| ID Token           | Write        | To authenticate with external services using OpenID Connect (OIDC).   |

Ensure that the GitHub App is configured with these permissions to allow the workflow to execute successfully.

## Actions Included

- **actions/checkout@v5**: Action to checkout the working directory, fetching the latest changes from the repository.
- **azure/login@v2**: Action to authenticate with Azure CLI using provided credentials.
- **ExakisNelite/devops-action-firewall@latest**: Actions to manage firewall rules for specified resources.
- **getsentry/action-github-app-token@v3.0.0**: Action to generate a token for authenticating with GitHub App.
- **hashicorp/setup-terraform@v3.1.2**: Action to set up Terraform with the specified version.
- **actions/upload-artifact@v4**: Action to upload artifact.
- **actions/download-artifact@v5**: Action to download artifact.
- Other Terraform-related actions such as `terraform init`, `terraform validate`, `terraform plan`, `terraform apply`, `terraform destroy`.

## How to use this workflow

This workflow allows for controlled and secure destruction of deployed Terraform infrastructure. To use it in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  destroy-infra:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-destroy.yml@v0.1.7
    with:
      TERRAFORM_VERSION: '1.6.4'
      WORKING_DIRECTORY: './terraform'
      ENVIRONMENT: 'development'
      RG_NAME_TFSTATE: 'rg-terraform-states'
      STORAGE_NAME_TFSTATE: 'terraformstatesstorage'
      CONTAINER_NAME_TFSTATE: 'tfstates'
      NAME_TFSTATE: 'my-project.tfstate'
      VARIABLES_FILE: './vars/dev.tfvars'
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Key considerations

1. This workflow performs a complete destruction of the Terraform infrastructure defined in the configuration files
2. It first generates a destruction plan to visualize the resources that will be deleted
3. A manual approval step is required before the actual destruction of resources
4. Use this workflow with caution, especially in production or pre-production environments

## Examples

### Destroy a set of resources with a variables file

The Terraform destroy workflow deprovisions all objects managed by a Terraform configuration.

```yaml
name: Example Usage of shared-tf-destroy

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  destroy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-destroy.yml@latest
    with:
      ENVIRONMENT: '<name of the GitHub environment associated>'
      WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
      RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State is stored>'
      STORAGE_NAME_TFSTATE: '<Storage Account Name where the State is stored>'
      CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State is stored>'
      NAME_TFSTATE: '<Terraform State file name>'
      VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
      TARGET_BRANCH: ${{ github.ref_name }}
      EVENT_NAME: ${{ github.event_name }}
      TERRAFORM_VERSION: '1.9.0'
    secrets:
      CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
      SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
      TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Destroy a set of resources passing variables

The Terraform destroy workflow deprovisions all objects managed by a Terraform configuration.

```yaml
name: Example Usage of shared-tf-destroy

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  destroy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-destroy.yml@latest
    with:
      ENVIRONMENT: '<name of the GitHub environment associated>'
      WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
      RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State is stored>'
      STORAGE_NAME_TFSTATE: '<Storage Account Name where the State is stored>'
      CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State is stored>'
      NAME_TFSTATE: '<Terraform State file name>'
      TARGET_BRANCH: ${{ github.ref_name }}
      EVENT_NAME: ${{ github.event_name }}
      TERRAFORM_VERSION: '1.9.0'
    secrets:
      CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
      SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
      TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
      VARIABLES: |
        variable1 = "\"${{ secrets.VARIABLE1 }}\""
        variable2 = "\"${{ secrets.VARIABLE2 }}\""
```

### Using both variable methods together

```yaml
name: Example Usage of shared-tf-destroy with both variable methods

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  destroy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-destroy.yml@latest
    with:
      # Other parameters...
      VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
    secrets:
      # Other secrets...
      VARIABLES: |
        variable1 = "\"${{ secrets.VARIABLE1 }}\""
        variable2 = "\"${{ secrets.VARIABLE2 }}\""
```

### With firewall management for Azure resources

```yaml
name: Example Usage of shared-tf-destroy with Firewall Management

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  destroy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-destroy.yml@latest
    with:
      # Other parameters...
      RG_NAME_RESOURCES_TO_OPEN: 'my-azure-resources-rg'
      OPEN_STORAGE_ACCOUNT_FIREWALL: true
      OPEN_KEY_VAULT_FIREWALL: true
      OPEN_AZURE_APPSERVICE_FIREWALL: true
    secrets:
      # Secrets...
```
