#!/bin/bash
# Script to bootstrap the entire infrastructure locally or for a new environment

echo "🚀 Bootstrapping Infrastructure..."
echo "1. Apply Terraform (DigitalOcean)"
# cd terraform/digitalocean && terraform init && terraform apply -auto-approve

echo "2. Wait for nodes to be ready..."
# sleep 60

echo "3. Run Ansible Playbook to setup K3s"
# cd ansible && ansible-playbook -i inventory/inventory.ini playbooks/setup-k3s-cluster.yml

echo "4. Install ArgoCD"
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "5. Apply ArgoCD Applications"
# kubectl apply -f kubernetes/argocd/applications.yaml

echo "✅ Bootstrap Complete!"