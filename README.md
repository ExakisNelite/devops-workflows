# cap-workflows

This repository contains the Github Actions workflow files which make up our catalog of GitHub templates for setting up CI/CD chains.

- Current Version: 0.3.0
- Version date: 16/09/2025

[![Release the GitHub Actions Workflows](https://github.com/meilleurtaux/cap-workflows/actions/workflows/internal-release-workflows.yml/badge.svg?branch=main)](https://github.com/meilleurtaux/cap-workflows/actions/workflows/internal-release-workflows.yml)

[Change History](./.github/CHANGELOG.md)

## Use repository

To use the workflows from this repository in your GitHub Actions workflows, you can reference them using the `uses` keyword with the format `Meilleurtaux/cap-workflows/.github/workflows/workflow-name.yml@tag`.

To pass named inputs to a called workflow, use the `with` keyword in a job. Use the keyword `secrets` to pass named secrets. For inputs, the data type of the input value must match the type specified in the called workflow (boolean, number, or string).

```yaml
jobs:
   call-workflow-passing-data:
     uses: Meilleurtaux/cap-workflows/.github/workflows/reusable-workflow.yml@main
     with:
       config-path: .github/labeler.yml
     secrets:
       envPAT: ${{ secrets.envPAT }}
```

### Best practices for using these workflows

1. Always reference a specific version tag (e.g., `@v0.1.7`) rather than `@main` for production workflows to ensure stability
2. Review the documentation for each workflow before use to understand its requirements and configuration options
3. Test workflows in a development environment before implementing them in production pipelines
4. Ensure proper permissions are set up for the GitHub tokens and secrets used by the workflows

If you have additional questions -> [FAQ](./.github/FAQ.md)

## List of available workflows

- [shared-create-release](./.github/docs/shared-create-release.md)
- [shared-notify-teams](./.github/docs/shared-notify-teams.md)
- [shared-php-deploy-app](./.github/docs/shared-php-deploy-app.md)
- [shared-php-rollback-app](./.github/docs/shared-php-rollback-app.md)
- [shared-tf-build-check-deploy-multirepos](./.github/docs/shared-tf-build-check-deploy-multirepos.md)
- [shared-tf-build-check-deploy](./.github/docs/shared-tf-build-check-deploy.md)
- [shared-tf-build-check](./.github/docs/shared-tf-build-check.md)
- [shared-tf-deploy](./.github/docs/shared-tf-deploy.md)
- [shared-tf-deploy-platform](./.github/docs/shared-tf-deploy-platform.md)
- [shared-tf-destroy-multirepos](./.github/docs/shared-tf-destroy-multirepos.md)
- [shared-tf-destroy](./.github/docs/shared-tf-destroy.md)

## Report a problem with the repository code

If you encounter any issue with the code in this repository, please open a GitHub issue using the provided templates. Make sure to include:

1. A descriptive title
2. Details of the problem encountered
3. Steps to reproduce the issue
4. Expected behavior vs. actual behavior
5. Screenshots or logs (if applicable)

For urgent issues, you can also reach out to [CAP - Core - GROUPE - CAP](mailto:a8e823dd.MEILLEURTAUXCOM.onmicrosoft.com@fr.teams.ms) describing the problem encountered.

## Collaborate on the repository

[Collaborate](./.github/CONTRIBUTE.md)
