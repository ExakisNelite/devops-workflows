# shared-php-rollback-app : 🔄 Rollback to previous version of a PHP application to Virtual Machine

## Description

This workflow automates the rollback of a PHP application on a VM by restoring the latest backup found in a specified directory. It supports both manual and workflow calls, and requires SSH credentials for the target VM.

## Usage

Reference this workflow in your GitHub Actions YAML:

```yaml
jobs:
  rollback:
    uses: meilleurtaux/cap-workflows/.github/workflows/shared-php-rollback-app.yml@main
    with:
      vm_host: 'your-vm-ip'
      vm_path: '/var/www/html'
      backup_path: '/tmp'
    secrets:
      VM_SSH_KEY: ${{ secrets.VM_SSH_KEY }}
      VM_USER: ${{ secrets.VM_USER }}
```

## Inputs

- `vm_host`: VM host IP address (required)
- `vm_path`: Deployment path on VM (default: `/var/www/html`)
- `backup_path`: Path where backups are stored on VM (default: `/tmp`)

## Secrets

- `VM_SSH_KEY`: SSH private key for VM access (required)
- `VM_USER`: SSH user for VM access (required)

## Steps

1. Setup SSH key
2. Find latest backup
3. Test SSH connection
4. Perform rollback

## Notes

- Make sure the backup directory contains valid backup folders named `backup-*`.
- The rollback step restores the latest backup found in the specified directory.
