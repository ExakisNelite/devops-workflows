# shared-tf-deploy-platform : 🚀 Deploy Terraform for DevOps Platform

----------------

## Description

This GitHub Actions workflow automates the validation, and deployment of Terraform infrastructure. It can be triggered manually or through other workflows. The workflow includes the following jobs:

1. **Generate Artifact Plan Name**: Generates the artifact plan name.
   - **Set Artifact Plan Name**: Builds an artifact plan name from the Terraform state file name.
2. **Terraform Init, Validate & Plan**: Initializes Terraform modules, validates Terraform code, and builds a plan.
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Login with Azure CLI**: Authenticates with Azure CLI using provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Login to Management with Azure CLI**: Authenticates with Azure CLI for management subscription.
   - **Opening Firewall for Management Shared KeyVault & Storage Account**: Opens firewall for shared management resources.
   - **Login to Identity with Azure CLI**: Authenticates with Azure CLI for identity subscription.
   - **Opening Firewall for Identity Shared KeyVault & Storage Account**: Opens firewall for shared identity resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHubOrganization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Check if container exists, otherwise create it**: Ensures the blob container for the Terraform state exists.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Terraform Destroy**: Destroys existing infrastructure if the `FORCE_DESTROY` input is set to true.
   - **Build Variables File**: Creates terraform.tfvars file from provided variables if available.
   - **Format terraform.tfvars**: Formats the terraform.tfvars file using terraform fmt.
   - **Terraform Validate**: Validates the Terraform configuration files.
   - **Terraform Plan**: Generates an execution plan for Terraform changes, with or without a variables file.
     - Supports both input variable files via the `VARIABLES_FILE` input and dynamically created terraform.tfvars via the `VARIABLES` secret.
     - Automatically detects and uses terraform.tfvars if it exists.
     - Adds a summary of plan changes to the workflow summary.
   - **Upload Resulting Terraform as Artifact**: Uploads the Terraform plan as an artifact.
   - **Close Resources Firewall**: Closes firewall rules for specified resources after execution.
   - **Close Management Resources Firewall**: Closes firewall rules for shared management resources.
   - **Close Identity Resources Firewall**: Closes firewall rules for shared identity resources.
3. **Terraform Approve & Apply**: Approves and applies Terraform changes to infrastructure.
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Download Terraform Plan Artifact**: Downloads the Terraform plan artifact for execution.
   - **Login with Azure CLI**: Authenticates with Azure CLI using provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Login to Management with Azure CLI**: Authenticates with Azure CLI for management subscription.
   - **Opening Firewall for Management Shared KeyVault & Storage Account**: Opens firewall for shared management resources.
   - **Login to Identity with Azure CLI**: Authenticates with Azure CLI for identity subscription.
   - **Opening Firewall for Identity Shared KeyVault & Storage Account**: Opens firewall for shared identity resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHubOrganization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Terraform Validate**: Validates the Terraform configuration files.
   - **Terraform Apply**: Applies Terraform changes if approved.
   - **Close Management Resources Firewall**: Closes firewall rules for shared management resources.
   - **Close Identity Resources Firewall**: Closes firewall rules for shared identity resources.
   - **Close Resources Firewall**: Closes firewall rules for specified resources after execution.

## Input Parameters

| Name                        | Type    | Required | Default   | Description                                                                 |
|-----------------------------|---------|----------|-----------|-----------------------------------------------------------------------------|
| TERRAFORM_VERSION           | string  | No       | 1.6.4     | The version of Terraform to use for deployment.                            |
| WORKING_DIRECTORY           | string  | No       | .         | The directory containing the Terraform files relative to the repository root. |
| TARGET_BRANCH               | string  | No       | main      | Target branch to checkout.                                                 |
| VARIABLES_FILE              | string  | No       | ''        | The path to the tfvars file. If provided, will be used with the -var-file flag. |
| ENVIRONMENT                 | string  | Yes      |           | The environment to deploy the infrastructure (e.g., development, production). |
| RG_NAME_TFSTATE             | string  | Yes      |           | Resource Group Name of the Storage Account where the State is stored.      |
| STORAGE_NAME_TFSTATE        | string  | Yes      |           | Storage Account Name where the State is stored.                            |
| CONTAINER_NAME_TFSTATE      | string  | Yes      |           | Container Name on the Storage Account where the State is stored.           |
| NAME_TFSTATE                | string  | Yes      |           | Terraform State file name.                                                 |
| USE_OIDC                    | boolean | No       | true      | Use OIDC for the backend.                                                  |
| FORCE_DESTROY               | boolean | No       | false     | If set to true, the existing infrastructure will be destroyed before applying changes. |
| EVENT_NAME                  | string  | No       | push      | The name of the event that triggered the workflow.                         |
| SHARED_RG_NAME_MANAGEMENT   | string  | Yes      |           | Azure Management Shared Resource Group Name.                               |
| SHARED_RG_NAME_IDENTITY     | string  | Yes      |           | Azure Identity Shared Resource Group Name.                                 |
| RG_NAME_RESOURCES_TO_OPEN   | string  | No       | ''        | Name of the Resource Group containing resources to open in the firewall.   |
| OPEN_STORAGE_ACCOUNT_FIREWALL | boolean | No     | false     | Open firewall for Storage Account.                                        |
| OPEN_AZURE_SQL_DATABASE_FIREWALL | boolean | No  | false     | Open firewall for Azure SQL Database.                                     |
| OPEN_AZURE_APPSERVICE_FIREWALL | boolean | No   | false     | Open firewall for Azure App Service.                                      |
| OPEN_AZURE_FUNCTIONAPP_FIREWALL | boolean | No  | false     | Open firewall for Azure Function App.                                     |
| OPEN_KEY_VAULT_FIREWALL     | boolean | No       | false     | Open firewall for Key Vault.                                              |
| OPEN_ACR_FIREWALL           | boolean | No       | false     | Open firewall for Azure Container Registry.                               |
| OPEN_APPCONFIGURATION_FIREWALL | boolean | No   | false     | Open firewall for Azure App Configuration.                                |

## Secrets Parameters

| Name                              | Type    | Required | Description                                                                 |
|-----------------------------------|---------|----------|-----------------------------------------------------------------------------|
| CLIENT_ID                         | string  | Yes      | Azure Service Principal Client ID.                                         |
| SUBSCRIPTION_ID                   | string  | Yes      | Azure Subscription ID.                                                     |
| TENANT_ID                         | string  | Yes      | Azure Tenant ID.                                                           |
| UNIVERSAL_GH_APP_ID_CODE          | string  | Yes      | GitHub App ID.                                                             |
| UNIVERSAL_GH_APP_PRIVATE_KEY_CODE | string  | Yes      | GitHub App Private Key.                                                    |
| SUBSCRIPTION_ID_MANAGEMENT        | string  | Yes      | Azure Management Subscription ID.                                          |
| SUBSCRIPTION_ID_IDENTITY          | string  | Yes      | Azure Identity Subscription ID.                                            |
| VARIABLES                         | string  | No       | Terraform variables. Will be written to terraform.tfvars if provided.      |

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

The GitHub App used in this workflow requires the following permissions to function correctly:

| Permission         | Access Level | Reason                                                                 |
|--------------------|--------------|------------------------------------------------------------------------|
| Actions            | Read/Write   | To manage workflow runs and artifacts.                                |
| Contents           | Read/Write   | To fetch and update repository content.                               |
| Pull Requests      | Read/Write   | To interact with pull requests during the workflow execution.         |
| Security Events    | Read/Write   | To access security-related events for the repository.                 |
| ID Token           | Write        | To authenticate with external services using OpenID Connect (OIDC).   |

Ensure that the GitHub App is configured with these permissions to avoid any issues during workflow execution.

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

This workflow is specifically designed for deploying Terraform infrastructures for the DevOps cloud platform. To use it in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  deploy-platform:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-deploy-platform.yml@v0.1.7
    with:
      TERRAFORM_VERSION: '1.6.4'
      WORKING_DIRECTORY: './terraform'
      ENVIRONMENT: 'production'
      RG_NAME_TFSTATE: 'rg-terraform-states'
      STORAGE_NAME_TFSTATE: 'terraformstatesstorage'
      CONTAINER_NAME_TFSTATE: 'tfstates'
      NAME_TFSTATE: 'platform.tfstate'
      SHARED_RG_NAME_MANAGEMENT: 'rg-management-shared'
      SHARED_RG_NAME_IDENTITY: 'rg-identity-shared'
      VARIABLES_FILE: './vars/prod.tfvars'
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      SUBSCRIPTION_ID_MANAGEMENT: ${{ secrets.AZURE_SUBSCRIPTION_ID_MANAGEMENT }}
      SUBSCRIPTION_ID_IDENTITY: ${{ secrets.AZURE_SUBSCRIPTION_ID_IDENTITY }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Key considerations

1. This workflow is more complex than the standard `shared-tf-deploy` workflow as it also manages connections to Azure subscriptions for Management and Identity
2. Ensure that the Service Principal credentials used have the appropriate permissions on all relevant subscriptions
3. Properly configure the shared resource group parameters (`SHARED_RG_NAME_MANAGEMENT` and `SHARED_RG_NAME_IDENTITY`)
4. Follow the DevOps Tools team best practices for Terraform file structure and variable configuration

## Examples

### Using the workflow to deploy Terraform resources with a variables file

```yaml
name: Example Usage of shared-tf-deploy-platform

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-deploy-platform.yml@latest
      with:
        ENVIRONMENT: '<name of the github environment associated to the deployment>'
        WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
        RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State is stored>'
        STORAGE_NAME_TFSTATE: '<Storage Account Name where the State is stored>'
        CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State is stored>'
        NAME_TFSTATE: '<Terraform State file name>'
        VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
        TARGET_BRANCH: ${{ github.ref_name }}
        EVENT_NAME: ${{ github.event_name }}
        TERRAFORM_VERSION: '1.10.5'
        SHARED_RG_NAME_MANAGEMENT: '<Management Shared Resource Group Name>'
        SHARED_RG_NAME_IDENTITY: '<Identity Shared Resource Group Name>'
      secrets:
        CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
        SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
        TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
        UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
        UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
        SUBSCRIPTION_ID_MANAGEMENT: ${{ secrets.SUBSCRIPTION_ID_MANAGEMENT }}
        SUBSCRIPTION_ID_IDENTITY: ${{ secrets.SUBSCRIPTION_ID_IDENTITY }}
```

### Using the workflow to deploy Terraform resources passing variables

```yaml
name: Example Usage of shared-tf-deploy-platform

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-deploy-platform.yml@latest
      with:
        ENVIRONMENT: '<name of the github environment associated to the deployment>'
        WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
        RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State is stored>'
        STORAGE_NAME_TFSTATE: '<Storage Account Name where the State is stored>'
        CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State is stored>'
        NAME_TFSTATE: '<Terraform State file name>'
        TARGET_BRANCH: ${{ github.ref_name }}
        EVENT_NAME: ${{ github.event_name }}
        TERRAFORM_VERSION: '1.10.5'
        SHARED_RG_NAME_MANAGEMENT: '<Management Shared Resource Group Name>'
        SHARED_RG_NAME_IDENTITY: '<Identity Shared Resource Group Name>'
      secrets:
        CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
        SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
        TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
        UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
        UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
        SUBSCRIPTION_ID_MANAGEMENT: ${{ secrets.SUBSCRIPTION_ID_MANAGEMENT }}
        SUBSCRIPTION_ID_IDENTITY: ${{ secrets.SUBSCRIPTION_ID_IDENTITY }}
        VARIABLES: |
          variable1                = "\"${{ secrets.VARIABLE1 }}"\""
          variable2                = "\"${{ secrets.VARIABLE2 }}"\""
```

### Using both variable methods together

```yaml
name: Example Usage of shared-tf-deploy-platform with both variable methods

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-deploy-platform.yml@latest
      with:
        # Other parameters...
        VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
      secrets:
        # Other secrets...
        VARIABLES: |
          variable1                = "\"${{ secrets.VARIABLE1 }}"\""
          variable2                = "\"${{ secrets.VARIABLE2 }}"\""
```

### Opening Firewalls for Additional Resources

```yaml
name: Example Usage of shared-tf-deploy-platform with Firewall Management

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
  deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-deploy-platform.yml@latest
      with:
        # Other parameters...
        RG_NAME_RESOURCES_TO_OPEN: 'my-azure-resources-rg'
        OPEN_STORAGE_ACCOUNT_FIREWALL: true
        OPEN_KEY_VAULT_FIREWALL: true
        OPEN_AZURE_APPSERVICE_FIREWALL: true
      secrets:
        # Secrets...
```
