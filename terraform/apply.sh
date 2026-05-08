#!/usr/bin/env bash
set -euo pipefail

# Run this script from the terraform directory:
# ./apply.sh

# Move to the root directory where ansible and terraform folders exist
cd "$(dirname "$0")/.."

# Read default LXC password from vault and keep it in-memory only.
echo "Extracting secure default password from Ansible Vault..."
PASSWORD=$(ansible-vault view ansible/group_vars/all/secrets.yml --vault-password-file ansible/vault_pass.txt | grep "terraform_default_password" | cut -d '"' -f 2)

if [ -z "$PASSWORD" ]; then
  echo "Error: Could not extract terraform_default_password from vault."
  exit 1
fi

# Proxmox API password must come from shell env, never from tfvars.
if [ -z "${TF_VAR_proxmox_api_pass:-}" ]; then
  echo "Error: TF_VAR_proxmox_api_pass is not set."
  echo "Example: export TF_VAR_proxmox_api_pass='***'"
  exit 1
fi

echo "Vault decrypted successfully. Executing terraform apply..."

# Pass the extracted password securely purely through memory (Environment Variable)
cd terraform
export TF_VAR_default_password="$PASSWORD"

terraform apply -auto-approve -parallelism=1
