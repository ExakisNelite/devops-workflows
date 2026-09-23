# Azure DevOps Pipeline Templates

This directory contains the Azure DevOps YAML pipeline templates which make up our catalog of reusable templates for setting up CI/CD chains on Azure DevOps.

The templates are organized by template type, following the Azure DevOps template hierarchy:

- **Stages templates** (`deployment-stage-*.yml`): full deployment stages (plan + apply/destroy with approval gates) that can be inserted into the `stages` section of a pipeline.
- **Jobs templates** (`job-*.yml`, `jobs-*.yml`): reusable jobs that can be inserted into the `jobs` section of a stage.
- **Steps templates** (`steps-*.yml`): reusable step sequences that can be inserted into the `steps` section of a job.
- **Deployment jobs templates** (`deployment-job-*.yml`): deployment jobs targeting an Azure DevOps environment (with approval gates configured in the Azure DevOps portal).

## Use the templates

### From the same repository

Reference the template directly by its relative path:

```yaml
stages:
  - template: azure-pipelines/templates/deployment-stage-terraform-apply.yml
    parameters:
      serviceConnection: my-service-connection
      rgNameTfstate: rg-terraform-state
      storageNameTfstate: sttfstate
      containerNameTfstate: tfstate
      nameTfstatePlan: myapp-plan.tfstate
      nameTfstateApply: myapp.tfstate
      environment: recette
```

### From another Azure DevOps repository

Declare this repository as a repository resource, then reference templates with the `@alias` suffix:

```yaml
resources:
  repositories:
    - repository: templates
      type: git
      name: MyProject/devops-workflows
      ref: refs/tags/v0.4.0

stages:
  - template: azure-pipelines/templates/deployment-stage-terraform-apply.yml@templates
    parameters:
      serviceConnection: my-service-connection
      # ...
```

> **Note**: Some templates fetch Terraform modules from an Azure DevOps Repos repository. They expect a repository resource named `iac-modules` to be declared in the consuming pipeline. Authentication uses the built-in `$(System.AccessToken)` — no external secret is needed.

### Best practices for using these templates

1. Always reference a specific version tag (e.g., `refs/tags/v0.4.0`) rather than `main` for production pipelines to ensure stability.
2. Review the documentation for each template before use to understand its requirements and parameters.
3. Test templates in a development environment before implementing them in production pipelines.
4. Configure approval gates on the Azure DevOps environments (e.g., `recette`, `production`) in the Azure DevOps portal — not in YAML.
5. Ensure the Azure service connection used has the required permissions on the tfstate storage account (data plane access via Entra ID) and on the target subscription.

## List of available templates

### Stages templates

- [deployment-stage-terraform-apply](./docs/deployment-stage-terraform-apply.md)
- [deployment-stage-terraform-destroy](./docs/deployment-stage-terraform-destroy.md)

### Jobs templates

- [jobs-terraform-checks](./docs/jobs-terraform-checks.md)
- [job-terraform-validate](./docs/job-terraform-validate.md)
- [job-terraform-validate-iac-modules](./docs/job-terraform-validate-iac-modules.md)
- [job-terraform-plan](./docs/job-terraform-plan.md)
- [job-create-release](./docs/job-create-release.md)

### Deployment jobs templates

- [deployment-job-terraform-apply](./docs/deployment-job-terraform-apply.md)
- [deployment-job-terraform-destroy](./docs/deployment-job-terraform-destroy.md)

### Steps templates

- [steps-azure-manage-firewall-open](./docs/steps-azure-manage-firewall-open.md)
- [steps-azure-manage-firewall-close](./docs/steps-azure-manage-firewall-close.md)
