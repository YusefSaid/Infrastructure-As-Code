# CTFd Platform Setup with Terraform and OpenStack

This project sets up a complete CTFd (Capture The Flag) platform using Infrastructure as Code principles with Terraform for OpenStack resource management and Ansible for application configuration. The setup includes CTFd, MariaDB, Redis, and Nginx as a reverse proxy.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Components](#components)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Daily Operations](#daily-operations)
- [Technical Details](#technical-details)

## Overview

This project automates the deployment of a CTFd platform with the following architecture:
- **OpenStack Infrastructure**: Terraform-managed VMs, networks, and security groups
- **VM Environment**: Ubuntu Noble LTS on OpenStack
- **Docker Containers**: CTFd application, MariaDB database, Redis cache, Nginx proxy
- **Network Access**: Direct access via floating IP from OpenStack
- **Automation**: Complete Infrastructure as Code with Terraform + Ansible integration

## Prerequisites

Before starting, ensure you have the following installed and configured:

- **OpenStack Environment**: Access to University of Agder's OpenStack cluster
- **Terraform** (1.12.1 or later)
- **Ansible** (2.9 or later)
- **OpenStack CLI** tools
- **SSH Key Pair**: group_33_key for VM access
- **OpenStack Credentials**: Group 33 authentication details

### Required Credentials

Ensure you have your `.cloudrc` file with:
```bash
export OS_USERNAME=IKT114_group_33_c43dda7c
export OS_PROJECT_NAME=IKT114_group_33_c43dda7c
export OS_PASSWORD=c43dda7c61c14324a260bbc0130433e4
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://kaun.uia.no:5000/v3
export OS_IDENTITY_API_VERSION=3
```

## Project Structure

```
exercise-05-infrastructure-as-code/
├── .cloudrc -----------------------------> # OpenStack credentials
├── README.md ----------------------------> # This file
├── terraform/ ---------------------------> # Infrastructure as Code
│   ├── providers.tf ---------------------> # Terraform provider configuration
│   ├── variables.tf ---------------------> # Variable definitions
│   ├── terraform.tfvars -----------------> # Variable values
│   ├── network.tf -----------------------> # Network infrastructure
│   ├── security.tf ----------------------> # Security groups and rules
│   ├── compute.tf -----------------------> # VM and floating IP configuration
│   ├── outputs.tf -----------------------> # Output definitions
│   ├── main.tf --------------------------> # Main configuration reference
│   ├── terraform.tfstate ----------------> # Current infrastructure state
│   └── terraform.tfstate.backup ---------> # State backup
├── ansible/ -----------------------------> # Configuration management
│   ├── ansible.cfg ----------------------> # Ansible configuration
│   ├── inventory.ini --------------------> # Dynamic inventory file
│   ├── deploy.yml -----------------------> # Main deployment playbook
│   ├── group_vars/ ----------------------> # Group variables
│   │   └── all.yml ----------------------> # Common variables
│   └── roles/ ---------------------------> # Ansible roles structure
│       ├── common/ ----------------------> # Common system setup
│       ├── docker/ ----------------------> # Docker installation
│       └── ctfd/ ------------------------> # CTFd application setup
│           ├── docker-compose.yml -------> # Container orchestration
│           └── files/
│               └── nginx.conf ------------> # Nginx reverse proxy config
└── scripts/ -----------------------------> # Automation scripts
    ├── deploy.sh ------------------------> # Basic deployment script
    ├── setup.sh -------------------------> # Environment setup
    ├── update-and-deploy.sh -------------> # Complete automation workflow
    └── update-inventory.sh --------------> # Dynamic inventory management
```

## Quick Start

### Automated Deployment

1. **Clone or navigate to the project directory:**
   ```bash
   cd ~/exercise-05-infrastructure-as-code
   ```

2. **Source OpenStack credentials:**
   ```bash
   source .cloudrc
   ```

3. **Run complete automated deployment:**
   ```bash
   ./scripts/update-and-deploy.sh
   ```

4. **Access CTFd:**
   - The script will display the URL when complete
   - Typically: `http://10.225.151.204`
   - Complete the initial setup wizard

### Manual Deployment Steps

If you prefer step-by-step deployment:

1. **Deploy Infrastructure:**
   ```bash
   cd terraform/
   terraform init
   terraform plan
   terraform apply
   ```

2. **Update Ansible Inventory:**
   ```bash
   cd ../scripts/
   ./update-inventory.sh
   ```

3. **Deploy Applications:**
   ```bash
   cd ../ansible/
   ansible-playbook -i inventory.ini deploy.yml
   ```

### First-Time CTFd Configuration

When you first access CTFd, configure:

1. **General**: Event name and description
2. **Mode**: Team or individual competition mode  
3. **Settings**: Visibility and participation rules
4. **Administration**: Create admin user account
5. **Style**: Optional branding and themes
6. **Date & Time**: Competition schedule (optional)

## Components

### Infrastructure Components (Terraform)

| Component | Description | Configuration File |
|-----------|-------------|-------------------|
| **Network** | Private network for VMs | `network.tf` |
| **Subnet** | 192.168.1.0/24 subnet | `network.tf` |
| **Router** | Internet gateway | `network.tf` |
| **Security Group** | Firewall rules (SSH, HTTP, HTTPS) | `security.tf` |
| **VM Instance** | Ubuntu Noble, medium flavor | `compute.tf` |
| **Floating IP** | Public IP address | `compute.tf` |

### Application Services (Docker)

| Service | Description | Port | Container Name |
|---------|-------------|------|----------------|
| **CTFd** | Main CTF platform | 8000 | ctfd-ctfd-1 |
| **MariaDB** | Database server | 3306 | ctfd-db-1 |
| **Redis** | Cache server | 6379 | ctfd-cache-1 |
| **Nginx** | Reverse proxy | 80 | ctfd-nginx-1 |

### Network Flow

- **External Access**: `Internet` → **Floating IP** → **VM**
- **Internal Proxy**: `Nginx:80` → **CTFd Container**: `8000`
- **Container Network**: CTFd ↔ MariaDB ↔ Redis

## Configuration

### Key Configuration Files

#### Terraform Variables (`terraform.tfvars`)
```hcl
group_number     = "33"
ssh_key_name     = "group_33_key"  
image_name       = "ubuntu-noble"
flavor_name      = "medium"
external_network = "provider"
```

#### Ansible Inventory (`inventory.ini`)
```ini
[ctfd_servers]
ctfd_server ansible_host=10.225.151.204 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/group_33_key
```

#### Docker Compose Configuration
```yaml
services:
  ctfd:
    image: ctfd/ctfd:latest
    ports: ["8000:8000"]
    environment:
      - DATABASE_URL=mysql+pymysql://ctfd:ctfd@db/ctfd
      - REDIS_URL=redis://cache:6379
      - SECRET_KEY=ctfd_secret_key_for_group_33
  
  nginx:
    image: nginx:latest
    ports: ["80:80"]
    
  db:
    image: mariadb:10.5
    environment:
      - MYSQL_USER=ctfd
      - MYSQL_PASSWORD=ctfd
      - MYSQL_DATABASE=ctfd
  
  cache:
    image: redis:4
```

#### Nginx Reverse Proxy
```nginx
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://ctfd:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Troubleshooting

### Common Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **SSH key missing** | "Permission denied" errors | Regenerate SSH key: `ssh-keygen -t rsa -f ~/.ssh/group_33_key` |
| **Terraform state issues** | "No state" or conflicts | Run `terraform refresh` or recreate resources |
| **Floating IP not working** | Connection timeouts | Check security group rules and IP association |
| **Container restart loops** | CTFd keeps restarting | Check Docker logs: `docker logs ctfd-ctfd-1` |
| **Database connection errors** | "Connection refused" | Verify MariaDB container and environment variables |
| **502 Bad Gateway** | Nginx proxy errors | Check CTFd container status and port mapping |

### Diagnostic Commands

#### Infrastructure Diagnostics
```bash
# Check OpenStack resources
source .cloudrc
openstack server list
openstack floating ip list
openstack security group show ctfd_security_group_33_unique_v2

# Check Terraform state  
cd terraform/
terraform show
terraform output
```

#### Application Diagnostics
```bash
# SSH into VM
ssh -i ~/.ssh/group_33_key ubuntu@10.225.151.204

# Check containers
sudo docker ps -a
sudo docker logs ctfd-ctfd-1
sudo docker logs ctfd-db-1
sudo docker logs ctfd-nginx-1

# Check services
sudo docker-compose -f /opt/ctfd/docker-compose.yml ps
```

#### Network Diagnostics
```bash
# Test connectivity
curl -I http://10.225.151.204
curl -I http://localhost  # from inside VM

# Check port bindings
sudo netstat -tlnp | grep -E ':(80|8000|3306|6379)'
```

## Daily Operations

### Starting Up
```bash
# Complete deployment
./scripts/update-and-deploy.sh

# Or infrastructure only
cd terraform/
terraform apply
```

### Checking Status
```bash
# Infrastructure status
openstack server list

# Application status  
ssh -i ~/.ssh/group_33_key ubuntu@10.225.151.204
sudo docker ps
```

### Updating Configuration
```bash
# Update inventory after infrastructure changes
./scripts/update-inventory.sh

# Redeploy applications
cd ansible/
ansible-playbook -i inventory.ini deploy.yml
```

### Shutting Down
```bash
# Destroy infrastructure
cd terraform/
terraform destroy

# Or stop containers only (keeps VM)
ssh -i ~/.ssh/group_33_key ubuntu@10.225.151.204
cd /opt/ctfd
sudo docker-compose down
```

## Technical Details

### OpenStack Configuration
- **Flavor**: medium (2 vCPUs, 4GB RAM)
- **Image**: ubuntu-noble (Ubuntu 24.04 LTS)
- **Network**: Private network with router to external
- **Security**: Custom security group with SSH, HTTP, HTTPS rules
- **Storage**: Ephemeral disk (data persistence via Docker volumes)

### Data Persistence
- **Database**: `/opt/ctfd/CTFd/mysql` (MariaDB data)
- **Redis Cache**: `/opt/ctfd/CTFd/redis` (Cache data)
- **CTFd Files**: `/opt/ctfd/CTFd/logs`, `/opt/ctfd/CTFd/uploads`
- **Configuration**: `/opt/ctfd/docker-compose.yml`, `/opt/ctfd/nginx.conf`

### Security Considerations
- SSH key-based authentication only
- Security group restricts access to required ports
- Database not exposed to external network
- Default passwords used (change for production)
- Internal container communication only

### Performance Optimization
- Redis caching for improved response times
- Nginx reverse proxy for static content handling
- Docker container resource limits (can be configured)
- Database optimized for CTFd workloads

## Automation Features

### Infrastructure as Code Benefits
- **Reproducible Infrastructure**: Terraform ensures consistent deployments
- **Version Control**: All configurations tracked in Git
- **Automated Workflows**: Scripts handle complete deployment process
- **Dynamic Configuration**: IP addresses automatically updated
- **State Management**: Terraform tracks and manages resource lifecycle

### Integration Points
- **Terraform → Ansible**: Floating IP passed automatically to inventory
- **OpenStack → SSH**: Automated key management and VM access
- **Docker → Nginx**: Container networking and reverse proxy setup
- **CI/CD Ready**: Scripts support automated deployment pipelines

## Additional Notes

### Customization Options
- Modify `terraform.tfvars` for different VM sizes or configurations  
- Update `deploy.yml` to change container configurations
- Customize `docker-compose.yml` template for additional services
- Adjust security group rules in `security.tf` as needed

### Backup Recommendations
- Export Terraform state: `terraform show > infrastructure-backup.txt`
- Backup CTFd data: Regular backup of `/opt/ctfd/CTFd/` directory
- Export challenges and users through CTFd admin interface
- Version control all configuration files

### Production Considerations
This setup is designed for educational use. For production:
- Implement proper SSL/TLS certificates
- Use secure secret management (HashiCorp Vault, etc.)
- Configure proper database backups and monitoring
- Implement logging and alerting systems
- Use production-grade database and cache configurations
- Consider high availability and load balancing

---

**Project**: Exercise 05 - Infrastructure As Code  
**Course**: IKT114 - IT Orchestration  
**Institution**: University of Agder  
**Group**: 33