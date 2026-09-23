# job-create-release : Create Release

---------------------------

## Description

This Azure DevOps job template creates a new release by computing the next semantic version and pushing Git tags. It includes the following steps:

1. **Checkout Repository**: Fetches the full history of the repository (required for the semver bump).
2. **Compute Next Semantic Version**: Finds the latest `vMAJOR.MINOR.PATCH` tag and computes the next version. The bump type is inferred from conventional commit messages since the last tag (`BREAKING CHANGE` or `!` suffix = major, `feat:` = minor, `fix:` = patch), falling back to `defaultBump`. A changelog (commits since the last tag) is written to `changelog.txt`.
3. **Push New Tag**: Pushes the new `vMAJOR.MINOR.PATCH` tag using `$(System.AccessToken)` (skipped for pull request builds).
4. **Update Major Floating Tag** (optional, `shouldTagMajor`): Moves the `vMAJOR` floating tag to the new version.
5. **Update Latest Tag** (optional, `shouldTagLatest`): Moves the `latest` tag to the new version.

## Parameters

| Name           | Type    | Default | Description                                                              |
|----------------|---------|---------|--------------------------------------------------------------------------|
| defaultBump    | string  | patch   | Default bump type when no conventional commit keyword is found (`major`, `minor` or `patch`). |
| shouldTagMajor | boolean | false   | Maintain a `vMAJOR` floating tag pointing to the latest version.         |
| shouldTagLatest| boolean | false   | Maintain a `latest` floating tag pointing to the latest version.         |
| mainBranch     | string  | main    | Main branch of the repository.                                           |

## Prerequisites

- The build service identity must have the **Contribute** and **Create tag** permissions on the repository, and the pipeline must allow the job to access the OAuth token (`persistCredentials: true` is set by the template).

## Usage example

```yaml
stages:
  - stage: Release
    jobs:
      - template: azure-pipelines/templates/job-create-release.yml
        parameters:
          defaultBump: minor
          shouldTagMajor: true
          shouldTagLatest: true
```
