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
| **repository**     | string  | current repository | The name of the repository where the release should be created. If not specified, uses the current repository. |
| **dry_run**        | boolean | false       | If set to true, the workflow will run in dry-run mode, where it simulates the release creation process without actually creating a release. |
| **environment**    | string  | production  | The environment to deploy to.                                              |
| **main_branch_target_repository**    | string  | main        | The main branch of the target repository.                                         |
| **default_bump**   | string  | patch       | The default bump to use when creating a new release. Can be `major`, `minor`, or `patch`. |
| **should_tag_major** | boolean | false      | If set to true, the major tag will be updated to point to the major release version. |
| **should_tag_latest** | boolean | false     | If set to true, the latest tag will be updated to point to the latest release. |
| **should_generate_release_note** | boolean | false | If set to true, a release note will be generated automatically from Jira tickets and GitHub data. |
| **release_notes_folder** | string | `.github/docs/release-notes/` | Path where the release notes markdown file will be generated. |
| **should_publish_release_note_confluence** | boolean | false | If set to true, the release notes will be published to Confluence. |
| **confluence_base_url** | string | `https://meilleurtaux.atlassian.net/wiki/` | Base URL for Confluence instance. |
| **confluence_email** | string | `compte.service.mtx@meilleurtaux.com` | Email address associated with your Confluence account. |
| **confluence_space_key** | string | empty | The key of the Confluence space where the release notes will be published. |
| **confluence_parent_page_id** | string | empty | The ID of the parent Confluence page under which the release notes page will be created. |
| **confluence_map_path** | string | `confluence-map.yml` | Path to the confluence-map.yml file relative to the workspace root. |
| **jira_base_url** | string | `https://meilleurtaux.atlassian.net` | Base URL for Jira instance used for fetching ticket details. |
| **jira_project_key** | string | empty | The key of the Jira project to browse work items (e.g., "CAP"). |
| **jira_email** | string | empty | Email address associated with the Jira account used for API authentication. |

## Required Permissions

To use this workflow, ensure that the GitHub App or token used has the following permissions:

| Permission         | Access Level | Reason                                                                 |
|--------------------|--------------|------------------------------------------------------------------------|
| **contents**       | write        | Required to push tags and create releases.                            |
| **metadata**       | read         | Required to access repository metadata.                               |
| **pull_requests**  | read         | Required to determine changes for version bumping.                    |
| **issues**         | read         | Required to include issue references in release notes (if applicable).|

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
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-create-release.yml@latest
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
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-create-release.yml@latest
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
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-create-release.yml@latest
    with:
      ENVIRONMENT: 'release'
      DEFAULT_BUMP: 'minor'
```

### Create a release with Jira integration and release notes

```yaml
name: Example Usage of shared-create-release with Jira

jobs:
  create-release:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-create-release.yml@latest
    with:
      ENVIRONMENT: 'release'
      DEFAULT_BUMP: 'minor'
      SHOULD_GENERATE_RELEASE_NOTE: true
      JIRA_BASE_URL: 'https://meilleurtaux.atlassian.net'
      JIRA_PROJECT_KEY: 'CAP'
      JIRA_EMAIL: 'compte.service.mtx@meilleurtaux.com'
      RELEASE_NOTES_FOLDER: '.github/docs/release-notes/'
    secrets:
      JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
```

### Create a release with Confluence integration

```yaml
name: Example Usage of shared-create-release with Confluence

jobs:
  create-release:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-create-release.yml@latest
    with:
      ENVIRONMENT: 'release'
      DEFAULT_BUMP: 'minor'
      SHOULD_GENERATE_RELEASE_NOTE: true
      SHOULD_PUBLISH_RELEASE_NOTE_CONFLUENCE: true
      JIRA_BASE_URL: 'https://meilleurtaux.atlassian.net'
      JIRA_PROJECT_KEY: 'CAP'
      JIRA_EMAIL: 'compte.service.mtx@meilleurtaux.com'
      CONFLUENCE_SPACE_KEY: 'MYSPACE'
      CONFLUENCE_PARENT_PAGE_ID: '123456789'
      CONFLUENCE_MAP_PATH: 'confluence-map.yml'
    secrets:
      JIRA_API_TOKEN: ${{ secrets.JIRA_API_TOKEN }}
      CONFLUENCE_API_TOKEN: ${{ secrets.CONFLUENCE_API_TOKEN }}
```

## How to use this workflow

To use this reusable workflow in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  release:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-create-release.yml@v0.1.7
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
3. Use the input parameters to customize the release creation behavior
4. **For Jira integration**: Set `SHOULD_GENERATE_RELEASE_NOTE` to `true` and provide the required Jira parameters (`JIRA_BASE_URL`, `JIRA_PROJECT_KEY`, `JIRA_EMAIL`) along with the `JIRA_API_TOKEN` secret
5. **For Confluence publishing**: In addition to Jira integration, set `SHOULD_PUBLISH_RELEASE_NOTE_CONFLUENCE` to `true` and provide Confluence parameters (`CONFLUENCE_SPACE_KEY`, `CONFLUENCE_PARENT_PAGE_ID`) along with the `CONFLUENCE_API_TOKEN` secret
