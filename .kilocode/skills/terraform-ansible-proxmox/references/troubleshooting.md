# Troubleshooting Guide for Terraform + Ansible + Proxmox

## Common Issues and Solutions

### Terraform Issues

#### Provider Connection Problems

**Error:** `Error: error waiting for SSH key to be ready`
```
Solution:
1. Verify Proxmox API endpoint is accessible
2. Check API credentials (username/password)
3. Ensure proper TLS configuration
4. Verify firewall rules allow API access
```

**Error:** `Error: proxmox_virtual_environment_vm.example: timeout while waiting for state to become 'running'`
```
Solution:
1. Check VM resource allocation (CPU, memory)
2. Verify storage availability
3. Ensure network bridge configuration
4. Check Proxmox host resources
```

#### State Management Issues

**Error:** `Error: Failed to persist state to backend`
```
Solution:
1. Verify backend configuration
2. Check permissions for state storage
3. Ensure network connectivity to backend
4. Use `terraform state pull/push` for recovery
```

**State Lock Issues:**
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID

# Check lock status
terraform state show
```

#### Resource Conflicts

**Error:** `Error: [ERROR] VM with ID "100" already exists`
```
Solution:
1. Use unique VM IDs
2. Implement proper resource naming
3. Check existing resources before creation
4. Use data sources to reference existing resources
```

### Ansible Issues

#### Connection Problems

**Error:** `FAILED! => SSH Error: Permission denied`
```
Solution:
1. Verify SSH key permissions (chmod 600)
2. Check SSH agent forwarding
3. Ensure correct inventory configuration
4. Test manual SSH connection
```

**Error:** `FAILED! => ERROR! the field 'hosts' has an invalid value`
```
Solution:
1. Check inventory file syntax
2. Verify group definitions
3. Ensure proper YAML/INI formatting
4. Test with `ansible -i inventory.ini --list-hosts all`
```

#### Module Execution Issues

**Error:** `FAILED! => {"changed": false, "msg": "proxmox_api_user is required"}`
```
Solution:
1. Verify variable definitions
2. Check Ansible Vault decryption
3. Ensure proper variable precedence
4. Use `ansible-playbook --extra-vars` for debugging
```

**Timeout Issues:**
```yaml
# Increase timeout in ansible.cfg
[defaults]
timeout = 60

# Or per task
- name: Long running task
  command: sleep 300
  async: 600
  poll: 10
```

#### Vault Issues

**Error:** `ERROR! Decryption failed`
```
Solution:
1. Verify vault password file
2. Check vault password correctness
3. Ensure proper file permissions
4. Use `ansible-vault view` to test decryption
```

### Proxmox-Specific Issues

#### API Access Problems

**Error:** `401 Unauthorized`
```
Solution:
1. Verify API credentials
2. Check user permissions in Proxmox
3. Ensure PAM vs PVE authentication
4. Review API token expiration
```

**Error:** `500 Internal Server Error`
```
Solution:
1. Check Proxmox service status
2. Review Proxmox logs (/var/log/pveproxy/access.log)
3. Verify API endpoint URL
4. Check system resources
```

#### VM Creation Issues

**Error:** `TASK ERROR: storage 'local-lvm' does not exist`
```
Solution:
1. Verify storage pool configuration
2. Check storage availability
3. Ensure proper permissions
4. Review storage pool status
```

**Network Configuration Issues:**
```bash
# Check bridge configuration
brctl show

# Verify network interface status
ip addr show

# Test network connectivity
ping -c 3 192.168.1.1
```

#### Resource Allocation Problems

**Error:** `not enough memory on node`
```
Solution:
1. Check available memory on Proxmox node
2. Review VM memory allocation
3. Consider memory ballooning
4. Monitor memory usage trends
```

### Debugging Techniques

#### Terraform Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Use terraform console for testing
terraform console
> var.vm_count
> data.proxmox_virtual_environment_nodes.available_nodes

# Validate configuration
terraform validate

# Check state
terraform state list
terraform state show proxmox_virtual_environment_vm.example
```

#### Ansible Debugging

```bash
# Verbose output
ansible-playbook -v playbook.yml
ansible-playbook -vv playbook.yml  # More verbose
ansible-playbook -vvv playbook.yml # Connection debugging

# Test connectivity
ansible -i inventory.ini -m ping all

# Test module execution
ansible -i inventory.ini -m command -a "uptime" webservers

# Use debug module
- name: Debug variable
  debug:
    var: proxmox_api_user
```

#### Proxmox Debugging

```bash
# Check Proxmox status
systemctl status pveproxy
systemctl status pvedaemon

# View logs
tail -f /var/log/pveproxy/access.log
tail -f /var/log/syslog | grep pve

# Check VM status
qm list
qm status 100

# Monitor resources
pvesh get /cluster/resources
```

### Performance Issues

#### Slow Terraform Operations

**Solutions:**
1. Reduce parallelism: `terraform apply -parallelism=1`
2. Use targeted applies: `terraform apply -target=resource.name`
3. Optimize provider configuration
4. Cache downloaded resources

#### Slow Ansible Execution

**Solutions:**
```yaml
# Use async tasks
- name: Long task
  command: slow_command
  async: 3600
  poll: 30

# Disable fact gathering if not needed
- hosts: all
  gather_facts: no

# Use free strategy for independent tasks
- hosts: webservers
  strategy: free
```

#### Proxmox Performance Issues

**Solutions:**
1. Monitor system resources with `htop` or `pvesh get /cluster/resources`
2. Check storage I/O with `iostat -x 1`
3. Review network performance with `iptraf` or `iftop`
4. Optimize VM configurations (CPU pinning, hugepages)

### Recovery Procedures

#### Terraform State Recovery

```bash
# Backup current state
terraform state pull > backup.tfstate

# Restore from backup
terraform state push backup.tfstate

# Remove orphaned resources
terraform state rm resource.name

# Import existing resources
terraform import resource.name RESOURCE_ID
```

#### Ansible Recovery

```bash
# Skip completed tasks
ansible-playbook playbook.yml --start-at-task="Install packages"

# Limit execution to specific hosts
ansible-playbook playbook.yml --limit webservers

# Use tags to run specific tasks
ansible-playbook playbook.yml --tags nginx
```

#### Proxmox Recovery

```bash
# Stop unresponsive VM
qm stop 100 --skiplock

# Reset VM configuration
qm destroy 100 --purge
# Then recreate

# Check cluster status
pvecm status

# Repair cluster (if needed)
pvecm expected 1
```

### Monitoring and Alerting

#### Set up Monitoring

```yaml
# Prometheus node exporter
- name: Install node exporter
  hosts: all
  become: yes
  roles:
    - prometheus_node_exporter

# Proxmox exporter
- name: Install Proxmox exporter
  hosts: proxmox_masters
  become: yes
  roles:
    - prometheus_proxmox_exporter
```

#### Log Aggregation

```yaml
# ELK stack for log management
- name: Install ELK stack
  hosts: monitoring
  become: yes
  roles:
    - elasticsearch
    - logstash
    - kibana
```

### Preventive Measures

#### Regular Maintenance

1. Update Terraform providers regularly
2. Keep Ansible collections updated
3. Monitor Proxmox system health
4. Regular backup verification
5. Security updates and patches

#### Documentation

1. Maintain runbooks for common procedures
2. Document troubleshooting steps
3. Keep inventory of all resources
4. Version control all configurations

#### Testing

1. Test playbooks with `--check` mode
2. Use molecule for role testing
3. Implement CI/CD pipelines
4. Regular integration testing

This troubleshooting guide should help resolve most common issues encountered when working with Terraform, Ansible, and Proxmox together.