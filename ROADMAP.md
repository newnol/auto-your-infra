# 🗺️ Roadmap: auto-your-infra

This document outlines the planned progression for the `auto-your-infra` repository, expanding from local Proxmox homelabs to multi-cloud environments like AWS and DigitalOcean.

## Phase 1: Foundation & Homelab (Proxmox) 🏗️
- [x] Establish standard directory structure (Ansible, Terraform, scripts).
- [x] Implement security best practices (`.gitignore`, `.example` templates, Ansible Vault).
- [ ] Refactor existing Proxmox VM provisioning playbooks into modular roles.
- [ ] Create base Ansible roles for common tools (Docker, Nginx, Prometheus/Grafana).
- [ ] Setup homelab networking and automated DNS updates.

## Phase 2: AWS Cloud Integration ☁️
- [ ] Initialize `terraform/aws/` environment for VPC, Subnets, and Security Groups.
- [ ] Implement Ansible dynamic inventory (`aws_ec2.yaml`) for AWS.
- [ ] Create playbooks for automated EC2 web server provisioning and configuration.
- [ ] Setup scripts for automated RDS (Database) and S3 (Storage) deployments.

## Phase 3: DigitalOcean Integration 🌊
- [ ] Initialize `terraform/digitalocean/` environment.
- [ ] Create Terraform scripts for DO Droplets, VPC, and Managed Databases.
- [ ] Implement Ansible dynamic inventory (`digitalocean.yaml`) for DO.
- [ ] Establish Cross-Cloud VPN/Wireguard between Proxmox, AWS, and DO.

## Phase 4: CI/CD & Automation 🤖
- [ ] Integrate GitHub Actions for continuous integration.
- [ ] Add linting for IaC: `ansible-lint`, `tflint`, and `yamllint`.
- [ ] Automate syntax checking and dry-runs (`terraform plan`, `ansible-playbook --check`) on Pull Requests.
- [ ] Setup Infrastructure Drift Detection and automated alerts.
