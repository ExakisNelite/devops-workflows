# shared-tf-build-check-deploy : 🚀 Build, Check & Deploy Terraform

----------------

## Description

This GitHub Actions workflow automates the build, validation process, and deployment of Terraform infrastructure. It can be triggered manually or through other workflows. The workflow includes the following jobs:

1. **Checkov**: Perform Checkov security analysis
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Login with Azure CLI**: Authenticates with Azure CLI using the provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHub Organization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Check if container exists, otherwise create it**: Ensures the Terraform state container exists in Azure Storage.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Build Variables File**: Creates terraform.tfvars file from provided variables if available.
   - **Format terraform.tfvars**: Formats the terraform.tfvars file using terraform fmt.
   - **Terraform Validate**: Validates the Terraform configuration files.
   - **Terraform Plan**: Generates an execution plan for Terraform changes.
     - Supports both input variable files and dynamically created terraform.tfvars.
     - Automatically detects and uses terraform.tfvars if it exists.
     - Captures plan output for later analysis and stores it as an artifact.
     - Adds a summary of plan changes to the workflow summary.
   - **Terraform Show**: Displays a detailed report of the Terraform execution plan.
   - **Checkov Exception**: Generates exceptions for Checkov security checks.
   - **Checkov Security Check**: Performs a Checkov security check, see [devops-action-terraform-checkov](https://github.com/ExakisNelite/devops-action-terraform-checkov) for more information.
   - **Close Resources Firewall**: Closes firewall rules for specified resources.

2. **SuperLinter**: Perform super-linter checks
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Super Linter**: Performs super-linter checks, see [devops-action-terraform-superlinter](https://github.com/ExakisNelite/devops-action-terraform-superlinter) for more information.

3. **Terraform Fmt**: Perform Formatting Checks
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Terraform fmt**: Formats Terraform files, see [devops-action-terraform-fmt](https://github.com/ExakisNelite/devops-action-terraform-fmt) for more information.

4. **Generate Artifact Plan Name**: Generates the artifact plan name.
   - **Set Artifact Plan Name**: Builds an artifact plan name from the Terraform state file name.

5. **Terraform Init, Validate & Plan**: Initializes Terraform modules, validates Terraform code, and builds a plan.
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Login with Azure CLI**: Authenticates with Azure CLI using provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHubOrganization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Check if container exists, otherwise create it**: Ensures the Terraform state container exists in Azure Storage.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Terraform Destroy**: Destroys existing infrastructure if the `FORCE_DESTROY` input is set to true.
   - **Build Variables File**: Creates terraform.tfvars file from provided variables if available.
   - **Format terraform.tfvars**: Formats the terraform.tfvars file using terraform fmt.
   - **Terraform Validate**: Validates the Terraform configuration files.
   - **Terraform Plan**: Generates an execution plan for Terraform changes.
     - Supports both input variable files and dynamically created terraform.tfvars.
     - Automatically detects and uses terraform.tfvars if it exists.
     - Captures plan output for later analysis and stores it as an artifact.
     - Adds a summary of plan changes to the workflow summary.
   - **Upload Resulting Terraform as Artifact**: Uploads the Terraform plan as an artifact.
   - **Close Resources Firewall**: Closes firewall rules for specified resources after execution.

6. **Terraform Approve & Apply**: Approves Terraform changes and applies them to the infrastructure.
   - **Checkout Working Directory**: Fetches the latest changes from the repository.
   - **Download Terraform Plan Artifact**: Downloads the Terraform plan artifact.
   - **Login with Azure CLI**: Authenticates with Azure CLI using provided credentials.
   - **Open Resources Firewall**: Opens firewall rules for specified resources.
   - **Generate token for the Organization Reader GitHub App**: Generates a token to authenticate with the GitHub App for organization access.
   - **Init the connection to ExakisNelite GitHubOrganization**: Initializes the connection to the organization to use Terraform modules.
   - **Setup Terraform**: Sets up Terraform with the specified version.
   - **Terraform Init**: Initializes the Terraform working directory and backend configuration.
   - **Terraform Validate**: Validates the Terraform configuration files.
   - **Terraform Apply**: Applies Terraform changes if approved.
   - **Close Resources Firewall**: Closes firewall rules for specified resources after execution.

## Input Parameters

| Name                              | Type    | Default       | Description                                                                                     |
|-----------------------------------|---------|---------------|-------------------------------------------------------------------------------------------------|
| **TERRAFORM_VERSION**             | string  | 1.6.4         | The version of Terraform to use for deployment.                                                |
| **WORKING_DIRECTORY**             | string  | .             | The directory containing the Terraform files relative to the repository root.                  |
| **VARIABLES_FILE**                | string  | ''            | The path to the tfvars file. If provided, will be used with the -var-file flag.                |
| **CHECKOV_CONFIG_DIRECTORY**      | string  | ./.github/configuration | The directory containing the Checkov configuration files.                                      |
| **TARGET_BRANCH**                 | string  | main          | Target branch to checkout.                                                                     |
| **DEFAULT_BRANCH**                | string  | (required)    | Default branch of the repository.                                                              |
| **ENVIRONMENT_CHECK**             | string  | integration   | The environment to check the infrastructure (e.g., development, production).                   |
| **ENVIRONMENT_DEPLOYMENT**        | string  | recette       | The environment to deploy the infrastructure (e.g., development, production).                  |
| **RG_NAME_TFSTATE**               | string  |               | Resource Group Name of the Storage Account where the State is stored.                          |
| **STORAGE_NAME_TFSTATE**          | string  |               | Storage Account Name where the State is stored.                                                |
| **CONTAINER_NAME_TFSTATE**        | string  |               | Container Name on the Storage Account where the State is stored.                               |
| **NAME_TFSTATE_BUILD_CHECK**      | string  |               | Terraform State file name for the check of the code.                                           |
| **NAME_TFSTATE_DEPLOY**           | string  |               | Terraform State file name for the deployment of the resources.                                 |
| **USE_OIDC**                      | boolean | true          | Use OIDC for the backend.                                                                      |
| **SHOULD_GENERATE_MODULES_DOCUMENTATION** | boolean | false | Should generate the documentation for the Terraform modules.                                   |
| **USE_TERRASCAN**                 | boolean | false         | Should use Terrascan to check the Terraform code.                                              |
| **LINTER_VALIDATE_ALL_CODEBASE**  | boolean | true          | Should validate the whole codebase.                                                            |
| **LINTER_VALIDATE_CHECKOV**       | boolean | true          | Should validate the Checkov rules.                                                             |
| **LINTER_VALIDATE_MARKDOWN**      | boolean | true          | Should validate the Markdown files.                                                            |
| **LINTER_VALIDATE_NATURAL_LANGUAGE** | boolean | true       | Should validate the Natural Language files.                                                    |
| **LINTER_VALIDATE_JSON**          | boolean | true          | Should validate the JSON files.                                                                |
| **TERRAFORM_TFLINT_CONFIG_FILE**  | string  | .tflint.hcl   | Filename for tfLint configuration (e.g., .tflint.hcl).                                         |
| **SHOULD_EXECUTE_LINTER**         | boolean | false         | Should execute the linter check control.                                                       |
| **FORCE_DESTROY**                 | boolean | false         | If set to true, the existing infrastructure will be destroyed before applying changes.          |
| **EVENT_NAME**                    | string  | push          | The name of the event that triggered the workflow.                                             |
| **RG_NAME_RESOURCES_TO_OPEN**     | string  | ''            | Name of the Resource Group containing the resources to open the firewall.                      |
| **OPEN_STORAGE_ACCOUNT_FIREWALL** | boolean | false         | Open firewall for Storage Account.                                                            |
| **OPEN_AZURE_SQL_DATABASE_FIREWALL** | boolean | false      | Open firewall for Azure SQL Database.                                                         |
| **OPEN_AZURE_APPSERVICE_FIREWALL** | boolean | false        | Open firewall for Azure App Service.                                                          |
| **OPEN_AZURE_FUNCTIONAPP_FIREWALL** | boolean | false       | Open firewall for Azure Function App.                                                         |
| **OPEN_KEY_VAULT_FIREWALL**       | boolean | false         | Open firewall for Key Vault.                                                                  |
| **OPEN_ACR_FIREWALL**             | boolean | false         | Open firewall for Azure Container Registry.                                                   |
| **OPEN_APPCONFIGURATION_FIREWALL** | boolean | false        | Open firewall for Azure App Configuration.                                                    |

## Secrets Parameters

| Name                              | Type    | Description                                                                                     |
|-----------------------------------|---------|-------------------------------------------------------------------------------------------------|
| **CLIENT_ID**                     | string  | Azure Service Principal Client ID.                                                             |
| **SUBSCRIPTION_ID**               | string  | Azure Subscription ID.                                                                          |
| **TENANT_ID**                     | string  | Azure Tenant ID.                                                                                |
| **UNIVERSAL_GH_APP_ID_CODE**      | string  | GitHub App ID.                                                                                 |
| **UNIVERSAL_GH_APP_PRIVATE_KEY_CODE** | string | GitHub App Private Key.                                                                        |
| **VARIABLES**                     | string  | Terraform variables. Will be written to terraform.tfvars if provided.                          |

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

| Permission         | Access Level | Description                                                                 |
|---------------------|--------------|-----------------------------------------------------------------------------|
| **Contents**        | Read/Write   | To fetch and update repository contents.                                   |
| **Pull Requests**   | Write        | To create, update, and merge pull requests.                                |
| **Actions**         | Write        | To trigger and manage GitHub Actions workflows.                            |
| **Security Events** | Write        | To access and manage security-related events, such as Checkov exceptions.  |
| **ID Token**        | Write        | To authenticate with external services using OpenID Connect (OIDC).        |

Ensure the GitHub App is configured with these permissions to avoid workflow execution issues.

## Actions Included

- **actions/checkout@v5**: Action to checkout the working directory, fetching the latest changes from the repository.

- **azure/login@v2**: Action to authenticate with Azure CLI using provided credentials.

- **ExakisNelite/devops-action-firewall@latest**: Actions to manage firewall rules for specified resources.

- **getsentry/action-github-app-token@v3.0.0**: Action to generate a token for authenticating with GitHub App.

- **hashicorp/setup-terraform@v3.1.2**: Action to set up Terraform with the specified version.

- **actions/upload-artifact@v4**: Action to upload artifact.

- **actions/download-artifact@v5**: Action to download artifact.

- Other Terraform-related actions such as `terraform init`, `terraform validate`, `terraform plan`, `terraform apply`, `terraform destroy`.

## Examples

### Using the workflow to check code and deploy Terraform resources with a variables file

```yaml
name: Example Usage of shared-tf-build-check-deploy

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
   build-check-and-deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy.yml@latest
      with:
         ENVIRONMENT_CHECK: '<name of the github environment associated to the integration>'
         ENVIRONMENT_DEPLOYMENT: '<name of the github environment associated to the deployment>'
         WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
         CHECKOV_CONFIG_DIRECTORY: ./.github/configuration
         TARGET_BRANCH: ${{ github.ref_name }}
         DEFAULT_BRANCH: 'main'
         RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the State are stored>'
         STORAGE_NAME_TFSTATE: '<Storage Account Name where the State are stored>'
         CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State are stored>'
         NAME_TFSTATE_BUILD_CHECK: '<Terraform State file name for the check of the code>'
         NAME_TFSTATE_DEPLOY: '<Terraform State file name for the deployment of the resources>'
         LINTER_VALIDATE_ALL_CODEBASE: false
         LINTER_VALIDATE_CHECKOV: false
         LINTER_VALIDATE_MARKDOWN: false
         LINTER_VALIDATE_NATURAL_LANGUAGE: false
         LINTER_VALIDATE_JSON: false
         EVENT_NAME: ${{ github.event_name }}
         VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
         TERRAFORM_VERSION: '1.9.0'
      secrets:
         CLIENT_ID: ${{ secrets.ARM_CLIENTID }}
         SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTIONID }}
         TENANT_ID: ${{ secrets.ARM_TENANTID_MTX }}
         UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
         UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
```

### Using the workflow to check code and deploy Terraform resources passing variables

```yaml
name: Example Usage of shared-tf-build-check-deploy

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
   build-check-and-deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy.yml@latest
      with:
         ENVIRONMENT_CHECK: '<name of the github environment associated to the integration>'
         ENVIRONMENT_DEPLOYMENT: '<name of the github environment associated to the deployment>'
         WORKING_DIRECTORY: './<Folder containing the code of the resources>/'
         CHECKOV_CONFIG_DIRECTORY: ./.github/configuration
         TARGET_BRANCH: ${{ github.ref_name }}
         DEFAULT_BRANCH: 'main'
         RG_NAME_TFSTATE: '<Resource Group Name of the Storage Account where the States are stored>'
         STORAGE_NAME_TFSTATE: '<Storage Account Name where the State are stored>'
         CONTAINER_NAME_TFSTATE: '<Container Name on the Storage Account where the State are stored>'
         NAME_TFSTATE_BUILD_CHECK: '${{ github.event.inputs.businessUnitShortName }}/${{ github.event.inputs.businessUnitShortName }}-firewall-rules-check.tfstate'
         NAME_TFSTATE_DEPLOY: '${{ github.event.inputs.businessUnitShortName }}/${{ github.event.inputs.businessUnitShortName }}-firewall-rules.tfstate'
         LINTER_VALIDATE_ALL_CODEBASE: false
         LINTER_VALIDATE_CHECKOV: false
         LINTER_VALIDATE_MARKDOWN: false
         LINTER_VALIDATE_NATURAL_LANGUAGE: false
         LINTER_VALIDATE_JSON: false
         EVENT_NAME: ${{ github.event_name }}      
         TERRAFORM_VERSION: '1.9.0'
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

### Using the workflow to check code and deploy Terraform resources with both variable methods

```yaml
name: Example Usage of shared-tf-build-check-deploy with both variable methods

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
   build-check-and-deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy.yml@latest
      with:
         # Other parameters...
         VARIABLES_FILE: './<path to the tfvars file ex: param.tfvars>'
      secrets:
         # Other secrets...
         VARIABLES: |
           variable1                = "\"${{ secrets.VARIABLE1 }}"\"
           variable2                = "\"${{ secrets.VARIABLE2 }}"\"
```

### Opening Firewalls for Additional Resources

```yaml
name: Example Usage of shared-tf-build-check-deploy with Firewall Management

permissions:
  id-token: write
  actions: write
  contents: write
  pull-requests: write
  security-events: write

jobs:
   build-check-and-deploy:
      uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy.yml@latest
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

This workflow combines the features of the `shared-tf-build-check` and `shared-tf-deploy` workflows in a single execution chain. To use it in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  build-check-deploy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-tf-build-check-deploy.yml@v0.1.7
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
    secrets:
      CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
      UNIVERSAL_GH_APP_ID_CODE: ${{ secrets.UNIVERSAL_GH_APP_ID_CODE }}
      UNIVERSAL_GH_APP_PRIVATE_KEY_CODE: ${{ secrets.UNIVERSAL_GH_APP_PRIVATE_KEY_CODE }}
      VARIABLES: |
        environment = "recette"
        location = "westeurope"
```

### Key considerations

1. This workflow performs both Terraform code validation (linting, security checks) and resource deployment
2. It uses two different Terraform state files: one for the verification phase (`NAME_TFSTATE_BUILD_CHECK`) and one for deployment (`NAME_TFSTATE_DEPLOY`)
3. Similarly, it uses two distinct environments: `ENVIRONMENT_CHECK` for the verification phase and `ENVIRONMENT_DEPLOYMENT` for deployment
4. This separation allows for code verification in an integration environment before deploying to a staging or production environment
