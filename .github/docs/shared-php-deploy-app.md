# shared-php-deploy-app : 🚀 Deployment of a PHP application to Virtual Machine

---------------------------

## Description

This GitHub Actions workflow deploys PHP applications directly to Virtual Machines via SSH. It downloads artifacts from GitHub Actions and securely transfers them to target VMs using SSH key authentication.

The workflow includes a single job:

**Deploy-VM**: Deploy to Virtual Machine

   1. **Verify artifact exists and target is safe**: Validates the artifact exists and checks the target VM for safe deployment.
   2. **Download build artifact**: Downloads the specified artifact from GitHub Actions using the GitHub API and extracts it.
   3. **Setup SSH key**: Configures SSH authentication for VM access.
   4. **Copy artifact to VM**: Transfers the extracted artifact to the target VM via SCP.
   5. **Test SSH connection**: Verifies SSH connectivity to the VM.
   6. **Deploy on VM**: Creates a backup of existing deployment, then executes deployment commands on the target VM.
   7. **Cleanup**: Removes temporary files and SSH keys from both runner and VM.

## Prerequisites

- A VM hosted in Microsoft Azure (you must know its private IP too);
- A self-hosted runner that is used by your project (also hosted in Microsoft Azure and "near" the VM used by your application);
- GitHub secret variables set correctly, especially for the SSH private key to access the VM as well as the username to reach the target VM.

## Input Parameters

| Name          | Type   | Default      | Description                                                    |
|---------------|--------|--------------|----------------------------------------------------------------|
| vm_host       | string | required     | VM host IP address for deployment target.                     |
| vm_path       | string | /var/www/html| Deployment path on the target VM.                             |
| artifact_name | string | required     | Name of the artifact to deploy. Must match the name used in the artifact workflow. |
| backup_path   | string | /tmp         | Path where backups will be stored on the VM.                  |

## Output Parameters

This workflow does not produce any output parameters.

## Secrets Parameters

| Name         | Type   | Description                              |
|--------------|--------|------------------------------------------|
| VM_SSH_KEY   | string | SSH private key for VM access.          |
| VM_USER      | string | SSH username for VM access.             |

## GitHub App Permissions

The GitHub App used in this workflow requires the following permissions to function correctly:

| Permission  | Access Level | Description                                              |
|-------------|--------------|----------------------------------------------------------|
| `contents`  | `read`       | Required to access repository contents.                  |
| `actions`   | `read`       | Required to download artifacts from GitHub Actions.     |

## How to use this workflow

To use this reusable workflow in your own GitHub Actions workflow, you can reference it with the following syntax:

```yaml
jobs:
  deploy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-php-deploy-app.yml@latest
    with:
      vm_host: '192.168.1.100'
      vm_path: '/var/www/html'
      artifact_name: 'myapp_v1.0.0_abc123.tar.gz'
      backup_path: '/var/backups'
    secrets:
      VM_SSH_KEY: ${{ secrets.VM_SSH_KEY }}
      VM_USER: ${{ secrets.VM_USER }}
```

### Key considerations

1. The artifact name should be the exact name used when uploading the artifact
2. Target VM must be accessible via SSH using the provided credentials
3. The deployment process includes artifact verification and safe deployment checks
4. The workflow runs on self-hosted runners and uses SSH for direct VM access

## Examples

### Deploy latest artifact from current workflow

```yaml
name: Build and Deploy

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build application
        run: echo "Building..."
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: myapp-build.tar.gz
          path: ./dist/

  deploy:
    needs: build
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-php-deploy-app.yml@latest
    with:
      vm_host: '10.0.1.100'
      vm_path: '/var/www/html'
      artifact_name: 'myapp-build.tar.gz'
    secrets:
      VM_SSH_KEY: ${{ secrets.VM_SSH_KEY }}
      VM_USER: ${{ secrets.VM_USER }}
```

### Deploy to production VM

```yaml
name: Deploy to Production

jobs:
  deploy:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-php-deploy-app.yml@latest
    with:
      vm_host: '10.0.1.100'
      vm_path: '/var/www/html'
      artifact_name: 'myapp-prod-build.tar.gz'
    secrets:
      VM_SSH_KEY: ${{ secrets.PRODUCTION_VM_SSH_KEY }}
      VM_USER: ${{ secrets.PRODUCTION_VM_USER }}
```

### Deploy to staging VM

```yaml
name: Deploy to Staging

jobs:
  deploy-staging:
    uses: ExakisNelite/devops-workflows/.github/workflows/shared-php-deploy-app.yml@latest
    with:
      vm_host: '10.0.1.200'
      vm_path: '/var/www/staging'
      artifact_name: 'myapp-staging-build.tar.gz'
    secrets:
      VM_SSH_KEY: ${{ secrets.STAGING_VM_SSH_KEY }}
      VM_USER: ${{ secrets.STAGING_VM_USER }}
```

## Infrastructure Requirements

### VM Configuration

For deployment to work, you need:

1. **Target VM**: A virtual machine accessible via SSH
2. **SSH Access**: VM must allow SSH connections from the GitHub Actions runner
3. **Network Connectivity**: Runner must be able to reach the VM on SSH port (22)
4. **SSH Key Pair**: Private key for authentication and corresponding public key on the VM

### VM Setup Requirements

Each target VM must have:

1. **SSH Server**: SSH daemon running and accepting connections
2. **User Account**: Valid user account with SSH access permissions
3. **Directory Permissions**: User must have write access to the deployment path
4. **SSH Key Authentication**: Public key added to `~/.ssh/authorized_keys`
5. **Deployment Path**: Specified deployment directory must exist and be writable

### Artifact Format

The artifact must be:

1. **GitHub Actions Artifact**: Uploaded using `actions/upload-artifact`
2. **ZIP Compressed**: GitHub automatically compresses artifacts as ZIP files
3. **Accessible**: Available in the current or specified workflow run

## Deployment Process

The deployment process follows these steps:

1. **Artifact Verification**: Checks that the specified artifact exists in the current workflow run
2. **VM Target Safety Check**: Verifies the target path is safe and removes any existing files
3. **Artifact Download**: Downloads and extracts the artifact from GitHub Actions
4. **SSH Setup**: Configures SSH key authentication for VM access
5. **File Transfer**: Copies the extracted artifact to the target VM via SCP
6. **SSH Connection Test**: Validates SSH connectivity to the VM
7. **Backup Creation**: Creates a timestamped backup of the existing deployment in the specified backup path if one exists
8. **Deployment Execution**: Runs deployment commands on the target VM
9. **Cleanup**: Removes temporary files from both runner and VM


## Monitoring and Security

The workflow includes comprehensive safety measures:

- **Artifact Existence Verification**: Ensures the artifact is available before proceeding
- **Target Path Safety**: Checks and cleans the target path on the VM
- **SSH Connection Validation**: Tests SSH connectivity before deployment
- **Automatic Backup**: Creates timestamped backups of existing deployments in configurable backup directory before overwriting
- **Timeout Protection**: All SSH operations have timeout limits to prevent hanging
- **Secure Cleanup**: Removes SSH keys and temporary files after deployment
