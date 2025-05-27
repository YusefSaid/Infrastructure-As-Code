#!/usr/bin/env bash
set -e

# 1) Compute absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

echo "Loading OpenStack credentials from .cloudrc"
source "$PROJECT_ROOT/.cloudrc"

echo "Checking prerequisites..."

# Ensure pip3 is installed
if ! command -v pip3 &>/dev/null; then
  echo "  pip3 not found, installing python3-pip"
  sudo apt-get update -qq
  sudo apt-get install -y python3-pip
fi

# Ensure ansible-playbook is installed
if ! command -v ansible-playbook &>/dev/null; then
  echo "  ansible-playbook not found, installing ansible via pip3"
  pip3 install --user ansible
  export PATH="$HOME/.local/bin:$PATH"
fi

# Force default callback plugin to avoid missing-yaml errors
export ANSIBLE_STDOUT_CALLBACK=default

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
cat > inventory.ini <<EOF
[ctfd_servers]
ctfd_server ansible_host=$FLOATING_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/group_33_key
EOF

echo "Running Ansible playbook"
ansible-playbook -i inventory.ini deploy.yml

echo "Deployment complete! CTFd available at http://$FLOATING_IP"
