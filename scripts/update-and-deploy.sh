#!/usr/bin/env bash
set -e

# 1) Compute absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

echo "Loading OpenStack credentials from .cloudrc"
source "$PROJECT_ROOT/.cloudrc"

echo "Deploying infrastructure with Terraform"
cd "$TERRAFORM_DIR"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
  echo "  terraform init"
  terraform init -input=false
fi

echo "  terraform plan"
terraform plan -out=tfplan

echo "  terraform apply"
terraform apply -auto-approve tfplan

echo "Retrieving server IP"
FLOATING_IP=$(terraform output -raw ctfd_server_ip)

echo "Writing Ansible inventory"
cd "$ANSIBLE_DIR"
mkdir -p inventory
cat > inventory/hosts.yml <<EOF
ctfd_servers:
  hosts:
    ctfd_server:
      ansible_host: $FLOATING_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/group_33_key
EOF

echo "Running Ansible playbook with role-based structure"
ansible-playbook -i inventory/hosts.yml playbook.yml

echo "Deployment complete! CTFd available at http://$FLOATING_IP"