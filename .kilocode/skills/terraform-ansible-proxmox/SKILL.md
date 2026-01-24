# Terraform + Ansible + Proxmox Homelab Infrastructure

## Overview
This skill provides a complete infrastructure-as-code solution for managing Proxmox homelab environments using Terraform for provisioning and Ansible for configuration management.

## Components

### Terraform
- Proxmox provider for VM/container management
- Infrastructure state management
- Declarative resource definitions

### Ansible
- Configuration management for VMs/containers
- Playbook-based automation
- Inventory management with dynamic host discovery

### Proxmox Integration
- VM creation and lifecycle management
- Network configuration
- Storage management
- Resource allocation

## Key Features

### Infrastructure Management
- Declarative VM/container definitions
- Automated provisioning workflows
- State tracking and drift detection

### Configuration Automation
- Post-provisioning configuration
- Service deployment
- Security hardening

### Homelab Optimization
- Resource-efficient deployments
- Network isolation
- Backup and recovery automation

## Use Cases

### Development Environments
- Consistent development VMs
- Testing environments
- CI/CD pipelines

### Service Hosting
- Web servers, databases, monitoring
- Container orchestration platforms
- Network services (DNS, DHCP, VPN)

### Learning and Experimentation
- Kubernetes clusters
- Network architecture testing
- Security tool deployment

## Best Practices

### Security
- Use Ansible Vault for secrets
- Implement least privilege access
- Regular security updates

### Organization
- Modular Terraform configurations
- Reusable Ansible roles
- Version control all infrastructure code

### Monitoring
- Implement logging and monitoring
- Set up alerts for resource usage
- Regular backup verification

## Getting Started

1. Configure Proxmox API access
2. Set up Terraform providers
3. Create Ansible inventory
4. Define infrastructure requirements
5. Deploy and configure

## References
- [Terraform Proxmox Provider](references/terraform-proxmox-provider.md)
- [Ansible Proxmox Modules](references/ansible-proxmox-modules.md)
- [Best Practices](references/best-practices.md)
- [Troubleshooting](references/troubleshooting.md)

## Assets
- [Terraform Configuration](assets/terraform/)
- [Ansible Playbooks](assets/ansible/)