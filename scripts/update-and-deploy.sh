#!/usr/bin/env bash
echo "Deploying infrastructure..."
cd terraform
terraform apply -auto-approve

echo "Getting server IP..."
FLOATING_IP=$(terraform output -raw ctfd_server_ip)

echo "Updating Ansible inventory..."
cd ../ansible
cat > inventory.ini << EOL
[ctfd_servers]
ctfd_server ansible_host=$FLOATING_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/group_33_key
EOL

echo "Deploying applications..."
ansible-playbook -i inventory.ini deploy.yml

echo "Deployment complete! CTFd available at: http://$FLOATING_IP"