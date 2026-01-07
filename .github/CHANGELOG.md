# Changelog

## Version 0.3.0

- Improve `shared-create-release` by adding capability to generate release note from a template including references to Jira work items.
- Update minor dependencies on GitHub Actions : Updates `softprops/action-gh-release` from `2.3.2` to `2.3.3`
- Update minor dependencies on GitHub Actions : Updates `actions/setup-node` from `v4` to `v5`
- Update minor dependencies on NPM Dependencies : Updates `axios` from `1.7.7` to `1.12.2`
- Update minor dependencies on NPM Dependencies : Updates `fs-extra` from `11.2.0` to `11.3.2`
- Update minor dependencies on NPM Dependencies : Updates `commander` from `12.1.0` to `14.0.1`
- Update minor dependencies on NPM Dependencies : Updates `dotenv` from `16.4.5` to `17.2.2`

## Version 0.2.0

- Rename `shared-rollback-php-deploy.yml` workflow to `shared-php-rollback-app.yml`
- Upgrade `actions/checkout` from v4 to v5
- Upgrade `actions/download-artifact` from v4 to v5
- Improve `shared-create-release` by adding capability to publish a handmade release note in markdown format to Confluence.

## Version 0.1.10

- Fix inconsistency during the upload step in the PHP workflow

## Version 0.1.9

- Improve `shared-php-deploy-app` workflow to use a dynamic artifact.
- Add rollback mechanism for the workflow mentioned above.
- rename the rollback file for better consistency with the other files.

## Version 0.1.8

- Add new workflows to publish a PHP application on Azure
- Update documentation and revamp some part of it

## Version 0.1.7

- Update minor dependencies on GitHub Actions : Updates `softprops/action-gh-release` from `2.2.2` to `2.3.2`
- Removing the token parameter `VARIABLES_REPOSITORY_TOKEN` in the multirepos worflows `shared-tf-build-check-deploy-multirepos` & `shared-tf-destroy-multirepos` and replace it by a token generated from the Github App identifiers parameters `UNIVERSAL_GH_APP_ID_CODE` and `UNIVERSAL_GH_APP_PRIVATE_KEY_CODE`.

## Version 0.1.6

- Add new shared tf workflow specific for CAP platform deployment : `shared-tf-deploy-platform`
- Enhance Terraform workflow with variable file handling with secrets and formatting, including improved readability and consistency in generated Terraform files.
- Add inputs for managing Azure resource group firewalls in Terraform workflows `shared-tf-build-check-deploy` and `shared-tf-deploy`
- Improved variable handling documentation to clarify usage of VARIABLES_FILE and VARIABLES secret.
- Modified internal-release-workflows to adjust concurrency group settings.
- Enhanced `shared-tf-build-check-deploy` and `shared-tf-build-check` workflows to include firewall management steps.
- Updated `shared-tf-destroy-multirepos` and `shared-tf-destroy workflows` to support new firewall management features.
- Bump `softprops/action-gh-release` from 2.2.1 to 2.2.2.

## Version 0.1.5

- Upgrade `terraform-docs/gh-actions` from 1.3.0 to 1.4.1

## Version 0.1.4

- Add unique ID in the artifact plan uploaded to artifacts in order to fix the problem of crash when two environments are chained with shared workflows `shared-tf-build-check-deploy`, `shared-tf-deploy`, `shared-tf-destroy`, `shared-tf-build-check-deploy-multirepos`, `shared-tf-destroy-multirepos`.

## Version 0.1.3

- Set the `--auth-mode` parameter to login to sign in using a Microsoft Entra security principal when creating the container in the storage account on Terraform workflows.

## Version 0.1.2

- Add container existence check and creation to Terraform workflows
- Enhance workflow documentation by adding examples for each workflow and update each workflow page with more details about inputs and permissions needed

## Version 0.1.1

- Remove quotes from checkov-skip output in workflow files

## Version 0.1.0

- Updates `hashicorp/setup-terraform` from 3.0.0 to 3.1.2
- Updates `terraform-docs/gh-actions` from 1.2.0 to 1.3.0

## Version 0.0.22

- Modify internal release workflow parameters

## Version 0.0.21

- Upgrade `cap-action-firewall` to `latest`
- Upgrade `cap-action-terraform-checkov` to `latest`
- Upgrade `cap-action-terraform-docs` to `latest`
- Upgrade `cap-action-terraform-fmt` to `latest`
- Upgrade `cap-action-terraform-superlinter` to `latest`

## Version 0.0.20

- Add new parameters for branch and tagging options in release workflow `shared-create-release`
- Review obsolete default values on shared workflows `shared-tf-deploy`, `shared-tf-destroy` and `shared-tf-destroy-multirepos`
- Add internal CI-CD workflows to make linter checks on workflows

## Version 0.0.19

- Upgrade `cap-action-firewall` to `0.0.8`

## Version 0.0.18

- Upgrade `cap-action-firewall` to `0.0.7`

## Version 0.0.17

- Add management of variables with Secrets instead of Terraform TFVARS File to terraform workflows
- Add TESTS_DIRECTORY parameter to workflow `shared-tf-build-check.yml`
- Upgrade `cap-action-terraform-fmt` to `0.0.3`
- Upgrade `cap-action-terraform-superlinter` to `0.0.7`

## Version 0.0.16

- Fix Security Issues : Update release workflow with permissions and action versions

## Version 0.0.15

- Upgrade `cap-action-firewall` to `0.0.6`

## Version 0.0.14

- Add branch main to release workflow triggers

## Version 0.0.13

- Add Terraform plan output summary to task summary in multiple workflows
- Change default value of linter check control to false in multi-repos workflows

## Version 0.0.12

- Upgrade workflows to include ARM\_SUBSCRIPTION\_ID in order to support the latest version of azurerm provider
- Upgrade workflows to include RG\_NAME\_TFSTATE variables to make fastest opening/closing firewall actions

## Version 0.0.11

- Update shared-tf-build-check.yml and Terraform docs configuration

## Version 0.0.10

- Refactor Terraform plan command in shared workflows to remove `-no-color` flag

## Version 0.0.9

- Update `shared-tf-build-check-deploy.yml` to handle multi repos checkout

## Version 0.0.8

- Update `shared-tf-build-check.yml` to handle pull request events

## Version 0.0.7

- Fix firewall opening action and update dependencies

## Version 0.0.6

- Review of workflow documentation

## Version 0.0.5

- Terraform shared workflow added: `TF-Destroy`

## Version 0.0.4

- Added Terraform shared workflow: `TF-Build-Check-Deploy`
- Terraform plan output added to execution summary on `TF-Deploy` & `TF-Build-Check-Deploy`

## Version 0.0.3

- `TARGET_BRANCH` parameter added to target branch on Git Checkout step in `TF-Build-Check` & `TF-Deploy`

## Version 0.0.2

- Added dev container definition for Codespaces
- Review of Terraform target version in `TF-Deploy` & `TF-Build-Check`
- Review of Dry Run parameter on `Create-Release`

## Version 0.0.1

- Creation of initial documentation
- Definition of code review process
- Definition of version management process
- Creation of FAQ page
- Creation of change log
- Implementation of shared workflows for Terraform (`Build & Check`, `Deploy`) and for release creation (`Create Release`)
