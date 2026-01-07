# shared-notify-teams : ✉️ Notify Teams on workflow completion

---------------------------

## Description

This GitHub Actions workflow sends notifications to Microsoft Teams about workflow completion status. It listens for workflow calls and can be integrated with other workflows to provide automated notifications about CI/CD pipeline results.

The workflow includes the following job:

1. **Send**: Send notification to Teams
   1. **Checkout code**: Fetches the latest changes from the repository.
   2. **Generate message**: Creates a formatted HTML message with workflow details including status, commit information, author, date, branch, environment, and links to the commit and workflow run.
   3. **Notify Teams**: Sends the generated message to Microsoft Teams using a webhook URL.

## Input Parameters

| Name        | Type   | Default  | Description                                    |
|-------------|--------|----------|------------------------------------------------|
| status      | string | required | Status of the notification (success or failure). |
| message     | string | optional | Content of the notification message.           |
| environment | string | preprod  | Environment for the notification.              |

## Secrets Parameters

| Name              | Type   | Description                    |
|-------------------|--------|--------------------------------|
| TEAMS_WEBHOOK_URL | string | Microsoft Teams webhook URL.   |

## GitHub App Permissions

The GitHub App used in this workflow requires the following permissions to function correctly:

| Permission  | Access Level | Description                                              |
|-------------|--------------|----------------------------------------------------------|
| `contents`  | `read`       | Required to access repository contents and commit data.  |

## How to use this workflow

To use this reusable workflow in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  notify-teams:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-notify-teams.yml@latest
    with:
      status: 'success'
      message: 'Deployment completed successfully!'
      environment: 'production'
    secrets:
      TEAMS_WEBHOOK_URL: ${{ secrets.TEAMS_WEBHOOK_URL }}
```

### Key considerations

1. Ensure the Teams webhook URL is properly configured and accessible
2. The workflow generates a comprehensive message with commit details and workflow links
3. Status can be either "success" or "failure" which affects the visual formatting of the message

## Examples

### Notify Teams on successful deployment

```yaml
name: Deploy and Notify

jobs:
  deploy:
    # Your deployment job here
    runs-on: ubuntu-latest
    steps:
      - name: Deploy application
        run: echo "Deploying..."

  notify-success:
    needs: deploy
    if: success()
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-notify-teams.yml@latest
    with:
      status: 'success'
      message: 'Application deployed successfully to production!'
      environment: 'production'
    secrets:
      TEAMS_WEBHOOK_URL: ${{ secrets.TEAMS_WEBHOOK_URL }}

  notify-failure:
    needs: deploy
    if: failure()
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-notify-teams.yml@latest
    with:
      status: 'failure'
      message: 'Application deployment failed. Please check the logs.'
      environment: 'production'
    secrets:
      TEAMS_WEBHOOK_URL: ${{ secrets.TEAMS_WEBHOOK_URL }}
```

### Simple notification with default environment

```yaml
name: CI Pipeline

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: echo "Running tests..."

  notify:
    needs: test
    if: always()
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-notify-teams.yml@latest
    with:
      status: ${{ needs.test.result == 'success' && 'success' || 'failure' }}
      message: 'CI pipeline completed'
    secrets:
      TEAMS_WEBHOOK_URL: ${{ secrets.TEAMS_WEBHOOK_URL }}
```

## Message Format

The notification message includes the following information:

- **Workflow name**: Name of the workflow that triggered the notification
- **Repository**: Repository name where the workflow ran
- **Status**: Visual indicator (green for success, red for failure)
- **Message**: Custom message provided via input parameter
- **Date**: Timestamp of the notification
- **Author**: Commit author information
- **Branch**: Branch name where the workflow ran
- **Environment**: Target environment
- **Commit**: Link to the specific commit
- **Workflow**: Link to the workflow run