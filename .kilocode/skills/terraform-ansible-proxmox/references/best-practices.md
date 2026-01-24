# Best Practices for Terraform + Ansible + Proxmox

## Infrastructure as Code Principles

### Version Control
- Store all infrastructure code in Git
- Use meaningful commit messages
- Implement code review processes
- Tag releases for production deployments

### Modular Design
- Break down infrastructure into reusable modules
- Use consistent naming conventions
- Implement proper variable scoping
- Separate concerns (network, compute, storage)

## Terraform Best Practices

### State Management
```hcl
# Use remote state for team collaboration
terraform {
  backend "s3" {
    bucket = "homelab-terraform-state"
    key    = "proxmox-infrastructure.tfstate"
    region = "us-east-1"
  }
}
```

### Resource Organization
```hcl
# Use locals for common values
locals {
  environment = "homelab"
  project     = "infrastructure"
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
  }
}

# Consistent resource naming
resource "proxmox_virtual_environment_vm" "web_server" {
  name      = "${local.project}-${local.environment}-web-${count.index + 1}"
  node_name = var.proxmox_node

  tags = local.common_tags

  # ... other configuration
}
```

### Variable Management
```hcl
# Use variables with validation
variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count > 0 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}

# Use variable files for different environments
# terraform.tfvars
vm_count = 3
vm_size  = "medium"
```

## Ansible Best Practices

### Inventory Management
```ini
# inventories/homelab.ini
[proxmox_masters]
proxmox1 ansible_host=192.168.1.10 ansible_user=root

[webservers]
web01 ansible_host=192.168.1.11 ansible_user=ubuntu
web02 ansible_host=192.168.1.12 ansible_user=ubuntu

[databases]
db01 ansible_host=192.168.1.13 ansible_user=ubuntu

[webservers:vars]
ansible_ssh_private_key_file=/home/user/.ssh/homelab_key
nginx_port=80

[databases:vars]
mysql_root_password="{{ vault_mysql_root_password }}"
```

### Playbook Structure
```yaml
# playbooks/site.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  roles:
    - common
    - nginx
    - php
    - monitoring

- name: Configure database servers
  hosts: databases
  become: yes
  roles:
    - common
    - mysql
    - monitoring

- name: Configure Proxmox hosts
  hosts: proxmox_masters
  become: yes
  roles:
    - proxmox
    - networking
```

### Role Organization
```
roles/
├── common/
│   ├── tasks/
│   ├── handlers/
│   ├── templates/
│   ├── vars/
│   └── defaults/
├── nginx/
│   ├── tasks/
│   ├── templates/
│   └── vars/
└── mysql/
    ├── tasks/
    ├── templates/
    └── vars/
```

## Security Best Practices

### Secrets Management
```yaml
# Use Ansible Vault for sensitive data
# group_vars/all/secrets.yml (encrypted)
---
proxmox_api_user: "root@pam"
proxmox_api_password: "{{ vault_proxmox_password }}"
db_root_password: "{{ vault_db_password }}"

# Use external secret management
# For production, consider HashiCorp Vault or AWS Secrets Manager
```

### Network Security
- Implement proper firewall rules
- Use VLANs for network isolation
- Enable TLS everywhere possible
- Regular security updates

### Access Control
```yaml
# Use least privilege principles
- name: Create limited user
  proxmox_user:
    userid: "terraform@pve"
    password: "{{ terraform_user_password }}"
    privileges:
      - VM.Allocate
      - VM.Config.CPU
      - VM.Config.Memory
    state: present
```

## Performance Optimization

### Terraform Performance
- Use `terraform plan -parallelism=n` to control concurrency
- Implement proper resource dependencies
- Use data sources to avoid redundant API calls
- Cache provider plugins

### Ansible Performance
```yaml
# Use async for long-running tasks
- name: Update packages
  apt:
    update_cache: yes
    upgrade: dist
  async: 3600
  poll: 10

# Use facts caching
ansible.cfg:
[defaults]
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
```

### Proxmox Optimization
- Use appropriate VM sizing
- Implement resource limits
- Use linked clones for similar VMs
- Monitor resource usage

## Monitoring and Logging

### Infrastructure Monitoring
```yaml
# Prometheus monitoring stack
- name: Deploy monitoring
  hosts: monitoring
  roles:
    - prometheus
    - grafana
    - node_exporter
```

### Logging
- Centralize logs using ELK stack or similar
- Implement structured logging
- Set up log rotation
- Monitor for security events

## Backup and Recovery

### Backup Strategy
```bash
# scripts/backup.sh
#!/bin/bash
# Backup Terraform state
terraform state pull > backup.tfstate

# Backup Ansible vault
cp ansible/group_vars/all/secrets.yml backup-secrets.yml

# Proxmox VM backups
vzdump 100 --compress gzip --storage backup-storage
```

### Disaster Recovery
- Test backup restoration regularly
- Document recovery procedures
- Implement multi-region backups when possible
- Use immutable infrastructure patterns

## Testing and Validation

### Terraform Testing
```hcl
# Use terraform validate
# Implement pre-commit hooks
# Use tflint for static analysis

# modules with proper validation
module "web_server" {
  source = "./modules/web-server"

  vm_count = var.vm_count
  vm_size  = var.vm_size

  # Validation in module
  validation {
    condition     = contains(["small", "medium", "large"], var.vm_size)
    error_message = "VM size must be small, medium, or large."
  }
}
```

### Ansible Testing
```yaml
# Use ansible-lint
# Implement molecule for role testing
# Use --check mode for dry runs

# Test playbooks
ansible-playbook --check --diff playbook.yml
```

## Documentation

### Code Documentation
- Document all variables and their purposes
- Include usage examples
- Maintain README files for each component
- Use comments for complex logic

### Runbooks
- Document deployment procedures
- Include troubleshooting guides
- Maintain incident response plans
- Regular documentation updates

## Continuous Integration

### CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
name: Deploy Infrastructure
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
    - name: Terraform Validate
      run: terraform validate

  deploy:
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deploy Infrastructure
      run: |
        terraform plan -out=tfplan
        terraform apply tfplan
```

This ensures automated validation and deployment of infrastructure changes.