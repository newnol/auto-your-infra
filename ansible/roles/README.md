# Ansible Roles Documentation

This directory contains reusable Ansible roles.

## Structure
Each role should follow the standard Ansible structure:
- `tasks/main.yml`: Main list of tasks to be executed by the role.
- `handlers/main.yml`: Handlers, which may be used by this role or even anywhere outside this role.
- `defaults/main.yml`: Default variables for the role.
- `vars/main.yml`: Other variables for the role.
- `files/`: Files which the role deploys.
- `templates/`: Templates which the role deploys.
- `meta/main.yml`: Metadata for the role, including dependencies.

## Available Roles
- `common`: Base configuration for all servers.
- `k3s`: Installation and configuration of K3s.
