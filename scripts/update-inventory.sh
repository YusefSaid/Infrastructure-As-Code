#!/usr/bin/env bash
cd terraform
FLOATING_IP=$(terraform output -raw ctfd_server_ip)
cd ../ansible/inventory
cat > hosts.yml << EOL
ctfd_servers:
  hosts:
    ctfd_server:
      ansible_host: $FLOATING_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/group_33_key
EOL
echo "Inventory updated with IP: $FLOATING_IP"