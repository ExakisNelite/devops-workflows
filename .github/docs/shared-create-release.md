# shared-create-release : 🚀 Create Release

----------------

## Description

This GitHub Actions workflow automates the process of creating a new release for a repository. It listens for workflow calls, allowing it to be triggered manually or through other workflows. When triggered, it performs the following steps:

1. **Checkout working directory**: Fetches the latest changes from the repository.

2. **Bump version and push tag**: Determines the version bump (patch, minor, major) based on the changes since the last release, updates the version accordingly, and pushes the new tag to the repository.

3. **Generate release notes** (optional): Automatically generates comprehensive release notes by:
   - Extracting Jira ticket IDs from commit messages
   - Fetching detailed ticket information from Jira API
   - Creating formatted Markdown with work items, metrics, and associated PRs
   - Supporting custom templates with placeholder replacement

4. **Create GitHub Release**: If a new tag is pushed, creates a GitHub release with the corresponding tag, including release notes generated from the changelog or custom generator.

5. **Publish to Confluence** (optional): Publishes the generated release notes to Confluence for centralized documentation.

6. **Tag the major release version**: Optionally updates the major tag to point to the major release version.

7. **Add latest tag**: Optionally updates the latest tag to point to the latest release.

## Input Parameters

| Name               | Type    | Default     | Description                                                                 |
|--------------------|---------|-------------|-----------------------------------------------------------------------------|
| **TARGET_REPOSITORY** | string  | current repository | The name of the repository where the release should be created. If not specified, uses the current repository. |
| **TARGET_BRANCH**  | string  | current ref | Target branch to checkout.                                                 |
| **WORKFLOWS_ORGANIZATION** | string | ExakisNelite | Organization name for the workflows repository.                       |
| **WORKFLOWS_REPOSITORY** | string | devops-workflows | The name of the workflows repository.                                |
| **WORKFLOWS_TARGET_BRANCH** | string | main     | Target branch to checkout from the workflows repository.                   |
| **ENVIRONMENT**    | string  | production  | The environment to deploy to.                                              |
| **MAIN_BRANCH_TARGET_REPOSITORY** | string | main | The main branch of the target repository.                                  |
| **DEFAULT_BUMP**   | string  | patch       | The default bump to use when creating a new release. Can be `major`, `minor`, or `patch`. |
| **SHOULD_TAG_MAJOR** | boolean | false     | If set to true, the major tag will be updated to point to the major release version. |
| **SHOULD_TAG_LATEST** | boolean | false    | If set to true, the latest tag will be updated to point to the latest release. |

## Required Permissions

To use this workflow, ensure that the GitHub App or token used has the following permissions:

| Permission         | Access Level | Reason                                                                 |
|--------------------|--------------|------------------------------------------------------------------------|
| **contents**       | write        | Required to push tags and create releases.                            |
| **metadata**       | read         | Required to access repository metadata.                               |
| **pull_requests**  | read         | Required to determine changes for version bumping.                    |

Ensure these permissions are granted to the GitHub App or token used to execute the workflow.

## Confluence Integration

This workflow supports automatic publication of release notes to Confluence. To use this feature:

### Required Secrets

| Name                      | Description                                                               |
|---------------------------|---------------------------------------------------------------------------|
| **GITHUB_TOKEN**          | GitHub personal access token with repository permissions (automatically provided by GitHub Actions). |
| **JIRA_API_TOKEN**        | API token for Jira authentication (required only if `should_generate_release_note` is `true`). |
| **CONFLUENCE_API_TOKEN**  | API token generated from your Confluence account for authentication (required only if `should_publish_release_note_confluence` is `true`). |

### Configuration File

The workflow requires a `confluence-map.yml` file in your repository that defines the mapping between Markdown files and Confluence pages. By default, this file is expected to be at the root of your repository, but you can specify a different path using the `confluence_map_path` parameter.

Example `confluence-map.yml` structure:

```yaml
settings:
  spaceKey: "YOURSPACE"
  dryRun: false

pages:
  - source: .github/docs/release-notes/release-v1.0.0.md
    title: "Release Note - v1.0.0"
    parent:
      id: "123456789"
    labels: ["release-note", "auto-generated"]
    upsert: true
```

### Setup Steps

1. **Create API Token**: Generate a Confluence API token from your Atlassian account settings
2. **Add Secret**: Add `CONFLUENCE_API_TOKEN` to your repository secrets
3. **Create Mapping File**: Create a `confluence-map.yml` file in your repository (or specify a different path)
4. **Configure Parameters**: Set the required Confluence parameters in your workflow call

## Actions Included

- **actions/checkout@v5**: Action to checkout the working directory, fetching the latest changes from the repository.

- **mathieudutour/github-tag-action@v6.1**: Action to bump the version and push the new tag to the repository. It determines the version bump (patch, minor, major) based on the changes since the last release.

- **softprops/action-gh-release@6cbd405e2c4e67a21c47fa9e383d020e4e28b836**: Action to create a GitHub release with the corresponding tag. Includes release notes generated from the changelog. The release is created only if a new tag is pushed.

- **cloudposse/github-action-major-release-tagger@v2**: Action to update the major tag to point to the major release version.

- **Git commands**: Commands to update the latest tag to point to the latest release.

## Examples

### Create a release with major and latest tags

```yaml
name: Example Usage of shared-create-release

jobs:
  create-release:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-create-release.yml@latest
    with:
      ENVIRONMENT: 'release'
      DEFAULT_BUMP: 'minor'
      SHOULD_TAG_MAJOR: true
      SHOULD_TAG_LATEST: true
```

### Create a release with latest tag only

```yaml
name: Example Usage of shared-create-release

jobs:
  create-release:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-create-release.yml@latest
    with:
      ENVIRONMENT: 'release'
      DEFAULT_BUMP: 'minor'
      SHOULD_TAG_LATEST: true
```

### Create a release without major or latest tags

```yaml
name: Example Usage of shared-create-release

jobs:
  create-release:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-create-release.yml@latest
    with:
      ENVIRONMENT: 'release'
      DEFAULT_BUMP: 'minor'
```

## How to use this workflow

To use this reusable workflow in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  release:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-create-release.yml@v0.1.7
    with:
      ENVIRONMENT: 'production'
      DEFAULT_BUMP: 'patch'
      SHOULD_TAG_LATEST: true
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Key considerations

1. Make sure to use a specific version of the workflow (e.g., `@v0.1.7`) to ensure the stability of your pipeline
2. Configure the access levels for the GitHub token correctly (permissions `contents: write` required)
