# devops-cloud-library

This repository serves as a centralized library for Infrastructure as Code (IaC), focusing primarily on Ansible playbooks, roles, and configurations. It follows best practices for structure, security, and reusability.

## Directory Structure

- `/ansible/playbooks/` - Contains executable Ansible playbooks (`.yml`).
- `/ansible/inventory/` - Stores inventory files (excluded from version control to prevent credential leakage).
- `/ansible/roles/` - Reusable Ansible roles.
- `/ansible/ansible.cfg` - Standard Ansible configuration.

## Getting Started

### 1. Setup Inventory

Copy the example inventory template to create your actual inventory file:

```bash
cp ansible/inventory/inventory.example.ini ansible/inventory/inventory.ini
```

**Important**: Fill in your real IP addresses, usernames, and passwords inside `ansible/inventory/inventory.ini`. This file is ignored by Git and will not be committed.

### 2. Run a Playbook

Navigate to the `ansible` directory and run a playbook using the `ansible-playbook` command. The configuration in `ansible.cfg` will automatically point to the correct inventory file.

```bash
cd ansible
ansible-playbook playbooks/test-connectivity.yml
```

*(You can replace `test-connectivity.yml` with the playbook you intend to run)*

## Security Notes

- The `.gitignore` at the root is strictly configured to ensure sensitive files like `inventory.ini`, `.vault_pass`, `*.retry`, and any `.pem`/`.key` SSH keys are **never** accidentally committed.
- Never hardcode real IPs, SSH keys, or passwords directly in playbooks or tracked files. Always use variables referencing the `inventory.ini` or encrypted using Ansible Vault.
