# Ansible Proxmox Modules Reference

## Overview
Ansible provides several modules for managing Proxmox Virtual Environment resources, allowing for comprehensive automation of virtual infrastructure.

## Core Modules

### proxmox
The main module for managing Proxmox VMs and containers.

```yaml
- name: Create a VM
  proxmox:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    node: pve
    name: test-vm
    vmid: 100
    memory: 2048
    cores: 2
    sockets: 1
    net:
      - name: eth0
        bridge: vmbr0
        tag: 10
    storage: local-lvm
    disks:
      - size: 20G
        type: virtio
        storage: local-lvm
    state: present
```

### proxmox_kvm
Advanced VM management module.

```yaml
- name: Create KVM VM
  proxmox_kvm:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    node: pve
    name: ubuntu-vm
    vmid: 101
    memory: 4096
    cores: 4
    cpu_type: host
    net:
      - model: virtio
        bridge: vmbr0
        firewall: 1
    virtio:
      - model: virtio
        size: 32G
        storage: local-lvm
    ostype: l26
    state: present
```

### proxmox_template
Manage VM templates.

```yaml
- name: Create VM template
  proxmox_template:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    node: pve
    src_vmid: 100
    name: ubuntu-template
    state: present
```

### community.general.proxmox
Community module for Proxmox management.

```yaml
- name: Manage Proxmox VM
  community.general.proxmox:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    node: pve
    vmid: 102
    state: present
    memory: 2048
    cores: 2
    name: web-server
    net:
      - name: eth0
        bridge: vmbr0
        ip: 192.168.1.10/24
        gw: 192.168.1.1
    disk:
      - size: 20
        storage: local-lvm
        type: virtio
```

## Container Management

### proxmox_lxc
Manage LXC containers.

```yaml
- name: Create LXC container
  proxmox_lxc:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    node: pve
    vmid: 200
    ostemplate: 'local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst'
    memory: 1024
    cores: 1
    storage: local-lvm
    netif:
      - name: eth0
        bridge: vmbr0
        ip: 192.168.1.20/24
        gw: 192.168.1.1
    state: started
```

## Network Management

### proxmox_network
Manage network configuration.

```yaml
- name: Configure network bridge
  proxmox_network:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    node: pve
    interface: vmbr0
    type: bridge
    bridge_ports: 'enp1s0'
    state: present
```

## Storage Management

### proxmox_storage
Manage storage pools.

```yaml
- name: Create storage pool
  proxmox_storage:
    api_user: root@pam
    api_password: "{{ proxmox_password }}"
    api_host: proxmox.example.com
    storage: ceph-pool
    type: rbd
    content:
      - images
      - rootdir
    state: present
```

## Best Practices

### Authentication
- Use Ansible Vault for API credentials
- Implement token-based authentication when possible
- Rotate credentials regularly

### Error Handling
- Use `ignore_errors` and `failed_when` appropriately
- Implement proper retry logic
- Log errors for debugging

### Performance
- Use async tasks for long-running operations
- Implement proper polling intervals
- Batch operations when possible

### Idempotency
- Ensure playbooks are idempotent
- Use proper state checking
- Implement proper change detection

## Common Patterns

### VM Lifecycle Management
```yaml
- name: Ensure VM exists and is running
  proxmox_kvm:
    api_user: "{{ proxmox_api_user }}"
    api_password: "{{ proxmox_api_password }}"
    api_host: "{{ proxmox_host }}"
    node: "{{ proxmox_node }}"
    name: "{{ vm_name }}"
    state: started
    memory: "{{ vm_memory }}"
    cores: "{{ vm_cores }}"
  register: vm_result

- name: Wait for VM to be ready
  wait_for:
    host: "{{ vm_result.vm.net[0].ip }}"
    port: 22
    timeout: 300
  when: vm_result.changed
```

### Configuration Management Integration
```yaml
- name: Deploy application stack
  hosts: proxmox_vms
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
      become: yes

    - name: Install required packages
      apt:
        name: "{{ packages }}"
        state: present
      become: yes

    - name: Configure services
      template:
        src: service.conf.j2
        dest: /etc/service.conf
      become: yes
      notify: restart service
```

## Troubleshooting

### Connection Issues
- Verify API endpoint accessibility
- Check API credentials
- Ensure proper SSL/TLS configuration

### Resource Conflicts
- Use unique VM IDs
- Check for existing resources
- Implement proper locking

### Performance Issues
- Monitor API rate limits
- Use appropriate timeouts
- Implement connection pooling