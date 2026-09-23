# steps-azure-manage-firewall-close : Close Azure Resources Firewall

---------------------------

## Description

This Azure DevOps **steps template** removes firewall exceptions previously added by [steps-azure-manage-firewall-open](./steps-azure-manage-firewall-open.md), so that Azure resources are not left open after the pipeline execution.

Two actions are supported:

- **CloseOneIp**: closes firewalls for the specified IP only (runs even on failure).
- **CloseAll**: removes all firewall exceptions on the selected resources.

## Parameters

| Name             | Type    | Default         | Description                                                              |
|------------------|---------|-----------------|--------------------------------------------------------------------------|
| action           | string  | (required)      | Action to perform: `CloseOneIp` or `CloseAll`.                           |
| serviceConnection| string  | (required)      | Azure service connection used to authenticate against ARM.               |
| ip               | string  | IPRUNNER        | IP to close. `IPRUNNER` resolves to the agent's public IP.               |
| ruleName         | string  | AzureDevOpsAgent| Name of the firewall rule to remove (where supported by the resource).   |
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
| scriptsDirectory | string  | $(Build.SourcesDirectory)/scripts | Directory containing the firewall management scripts (close-firewalls.ps1). |

## Usage example

```yaml
steps:
  - template: azure-pipelines/templates/steps-azure-manage-firewall-close.yml
    parameters:
      action: CloseOneIp
      serviceConnection: my-service-connection
      rg: rg-terraform-state
      storageAccount: true
```

> **Note**: This template should always run, even when previous steps fail. When used inside a job template of this repository, this is already handled by the calling template.
