# Homelab Infrastructure

This project sets up a homelab infrastructure using Terraform, Proxmox, and Ansible.

## Project Structure

```
homelab-infra/
├── ansible/
│   ├── inventories/
│   │   ├── homelab.ini
│   │   └── prod.ini
│   ├── playbooks/
│   │   └── network-setup.yml
│   ├── group_vars/
│   │   └── all/
│   │       └── secrets.yml  # Encrypted with Ansible Vault
│   ├── roles/
│   └── vault_pass.txt  # Vault password file (change this!)
├── terraform/
│   └── main.tf
├── docs/
│   └── architecture.md
├── scripts/
│   ├── backup.sh
│   └── restore.sh
├── .gitignore
└── README.md
```

## Ansible Vault Usage

Ansible Vault is used to encrypt sensitive data like API credentials. **Encrypted vault files are safe to commit to GitHub** since the content is encrypted and can only be decrypted with the vault password.

### Workflow

1. **Create/Edit Vault File**:
   ```bash
   # Create new vault file
   ansible-vault create --vault-password-file ansible/vault_pass.txt ansible/group_vars/all/secrets.yml

   # Edit existing vault file
   ansible-vault edit --vault-password-file ansible/vault_pass.txt ansible/group_vars/all/secrets.yml
   ```

2. **Run Playbook**:
   ```bash
   ansible-playbook ansible/playbooks/network-setup.yml --ask-vault-pass
   # Or use password file:
   ansible-playbook ansible/playbooks/network-setup.yml --vault-password-file ansible/vault_pass.txt
   ```

3. **View Encrypted File** (without decrypting):
   ```bash
   ansible-vault view --vault-password-file ansible/vault_pass.txt ansible/group_vars/all/secrets.yml
   ```

4. **Change Vault Password**:
   ```bash
   ansible-vault rekey --vault-password-file ansible/vault_pass.txt ansible/group_vars/all/secrets.yml
   ```

### Example Secrets File

```yaml
---
proxmox_api_user: "root@pam"
proxmox_api_pass: "your_proxmox_password"
db_password: "supersecret"
```

### CI/CD Integration

For automated deployments, use `--vault-id` with a secrets manager or password file.

## Getting Started

1. Update `ansible/group_vars/all/secrets.yml` with your actual credentials.
2. Change the vault password in `ansible/vault_pass.txt`.
3. Run Terraform: `cd terraform && terraform apply`
4. Run Ansible: `ansible-playbook ansible/playbooks/network-setup.yml --vault-password-file ansible/vault_pass.txt`

## Backup and Restore

Use the scripts in `scripts/` directory for backup and restore operations.