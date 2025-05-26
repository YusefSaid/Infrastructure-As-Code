#!/usr/bin/env bash

# Deployment script for infrastructure

# Check if .cloudrc exists
if [ ! -f ".cloudrc" ]; then
  echo "ERROR: .cloudrc file not found!"
  echo "Please create a .cloudrc file with your OpenStack credentials."
  exit 1
fi

# Source OpenStack credentials
source .cloudrc

# Apply Terraform configuration
cd terraform
terraform apply -auto-approve

# Get the floating IP of the CTFd server
FLOATING_IP=$(terraform output -raw ctfd_server_ip)

# Update Ansible inventory with floating IP
sed -i "s/ansible_host=.*/ansible_host=$FLOATING_IP/" ../ansible/inventory.ini

# Wait for SSH to be available
echo "Waiting for SSH to become available..."
while ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$FLOATING_IP echo "SSH is up"; do
  sleep 5
done

# Run Ansible playbook
cd ../ansible
ansible-playbook deploy.yml

echo "Deployment complete!"
echo "CTFd is now available at: http://$FLOATING_IP"