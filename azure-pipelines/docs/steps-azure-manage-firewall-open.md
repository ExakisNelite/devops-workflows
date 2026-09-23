# steps-azure-manage-firewall-open : Open Azure Resources Firewall

---------------------------

## Description

This Azure DevOps **steps template** opens firewall rules on Azure resources to allow access from the Azure DevOps agent during pipeline execution. It resolves the agent's public IP (or uses a provided IP) and adds a firewall exception on the selected resource types.

It is designed to be paired with [steps-azure-manage-firewall-close](./steps-azure-manage-firewall-close.md), which removes the exception at the end of the job (even on failure).

## Parameters

| Name             | Type    | Default         | Description                                                              |
|------------------|---------|-----------------|--------------------------------------------------------------------------|
| serviceConnection| string  | (required)      | Azure service connection used to authenticate against ARM.               |
| ip               | string  | IPRUNNER        | IP to open. `IPRUNNER` resolves to the agent's public IP.                |
| ruleName         | string  | AzureDevOpsAgent| Name of the firewall rule to create (where supported by the resource).   |
| rg               | string  | ''              | Scope to a specific resource group (empty = whole subscription).         |
| storageAccount   | boolean | false           | Include storage accounts.                                                |
| azureSqlDatabase | boolean | false           | Include Azure SQL databases.                                             |
| appService       | boolean | false           | Include App Services.                                                    |
| functionApp      | boolean | false           | Include Function Apps.                                                   |
| keyvault         | boolean | false           | Include Key Vaults.                                                      |
| acr              | boolean | false           | Include Azure Container Registries.                                      |
| appConfiguration | boolean | false           | Include App Configuration stores.                                        |
| postgreSQL       | boolean | false           | Include PostgreSQL servers.                                              |
| exclude          | string  | improbable__name  | Resource names to exclude from the firewall update (comma-separated).    |
| scriptsDirectory | string  | $(Build.SourcesDirectory)/scripts | Directory containing the firewall management scripts (open-firewalls.ps1). |

## Usage example

```yaml
steps:
  - template: azure-pipelines/templates/steps-azure-manage-firewall-open.yml
    parameters:
      serviceConnection: my-service-connection
      rg: rg-terraform-state
      storageAccount: true

  # ... other steps ...

  - template: azure-pipelines/templates/steps-azure-manage-firewall-close.yml
    parameters:
      action: CloseOneIp
      serviceConnection: my-service-connection
      rg: rg-terraform-state
      storageAccount: true
```
