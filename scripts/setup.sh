#!/usr/bin/env bash

# Setup script for OpenStack environment

# Check if .cloudrc exists
if [ ! -f ".cloudrc" ]; then
  echo "ERROR: .cloudrc file not found!"
  echo "Please create a .cloudrc file with your OpenStack credentials."
  exit 1
fi

# Source OpenStack credentials
source .cloudrc

# Check if OpenStack CLI is installed
if ! command -v openstack &> /dev/null; then
  echo "Installing OpenStack CLI..."
  pip install python-openstackclient
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
  echo "Installing Terraform..."
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update && sudo apt-get install -y terraform
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
  echo "Installing Ansible..."
  sudo apt update
  sudo apt install -y ansible
fi

# Initialize Terraform
cd terraform
terraform init

echo "Environment setup complete!"
echo "Next steps:"
echo "1. Update terraform.tfvars with your group number and SSH key name"
echo "2. Run ./scripts/deploy.sh to deploy the infrastructure"