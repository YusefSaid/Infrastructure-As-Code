# CTFd Platform Setup with Terraform and OpenStack

This project sets up a complete CTFd (Capture The Flag) platform using Infrastructure as Code principles with Terraform for OpenStack resource management and Ansible for application configuration. The setup follows Exercise 04's role-based Ansible structure and includes CTFd, MariaDB, Redis, and Nginx as a reverse proxy.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Components](#components)
- [Ansible Role-Based Architecture](#ansible-role-based-architecture)
- [Automation Scripts](#automation-scripts)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Daily Operations](#daily-operations)
- [Technical Details](#technical-details)

## Overview

This project automates the deployment of a CTFd platform with the following architecture:
- **OpenStack Infrastructure**: Terraform-managed VMs, networks, and security groups
- **VM Environment**: Ubuntu Noble LTS on OpenStack
- **Configuration Management**: Role-based Ansible structure (Exercise 04 compliant)
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
├── ansible/ -----------------------------> # Configuration management (Role-based)
│   ├── ansible.cfg ----------------------> # Ansible configuration
│   ├── playbook.yml ---------------------> # Main orchestrator (Exercise 04 style)
│   ├── inventory/ -----------------------> # Inventory management
│   │   └── hosts.yml --------------------> # Host definitions (YAML format)
│   ├── group_vars/ ----------------------> # Group variables
│   │   └── all.yml ----------------------> # Common variables
│   └── roles/ ---------------------------> # Ansible roles structure
│       ├── common/ ----------------------> # Common system setup
│       │   └── tasks/
│       │       └── main.yml -------------> # System packages and updates
│       ├── docker/ ----------------------> # Docker installation
│       │   └── tasks/
│       │       └── main.yml -------------> # Docker and Docker Compose setup
│       ├── mariadb/ ---------------------> # MariaDB database setup
│       │   └── tasks/
│       │       └── main.yml -------------> # Database directory creation
│       ├── redis/ -----------------------> # Redis cache setup
│       │   └── tasks/
│       │       └── main.yml -------------> # Redis directory creation
│       ├── ctfd/ ------------------------> # CTFd application setup
│       │   ├── tasks/
│       │   │   └── main.yml -------------> # CTFd configuration
│       │   └── files/
│       │       └── docker-compose.yml ---> # Container orchestration
│       └── nginx/ -----------------------> # Nginx reverse proxy
│           ├── tasks/
│           │   └── main.yml -------------> # Nginx configuration
│           └── templates/
│               └── nginx.conf -----------> # Nginx reverse proxy config
└── scripts/ -----------------------------> # Automation scripts
    ├── setup.sh -------------------------> # Environment setup and initialization
    ├── update-inventory.sh --------------> # Dynamic inventory management
    └── update-and-deploy.sh -------------> # Complete automation workflow
```

## Quick Start

### Automated Deployment (Recommended)

1. **Clone or navigate to the project directory:**
   ```bash
   cd ~/exercise-05-infrastructure-as-code
   ```

2. **Initial environment setup (first time only):**
   ```bash
   ./scripts/setup.sh
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
   ./scripts/update-inventory.sh
   ```

3. **Deploy Applications with Role-Based Playbook:**
   ```bash
   cd ansible/
   ansible-playbook -i inventory/hosts.yml playbook.yml
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

## Ansible Role-Based Architecture

This project follows Exercise 04's role-based Ansible structure, where each service is managed by a dedicated role:

### Role Structure

| Role | Purpose | Key Tasks |
|------|---------|-----------|
| **`common`** | System preparation | Update packages, install prerequisites |
| **`docker`** | Container platform | Install Docker, Docker Compose, start services |
| **`mariadb`** | Database setup | Create data directories, configure environment |
| **`redis`** | Cache setup | Create data directories, configure environment |
| **`ctfd`** | Application setup | Deploy configuration, manage Docker Compose |
| **`nginx`** | Reverse proxy | Configure proxy settings, manage routing |

### Playbook Orchestration

The main `playbook.yml` orchestrates all roles:
```yaml
- name: Deploy CTFd Infrastructure
  hosts: ctfd_servers
  become: yes
  roles:
    - common
    - docker
    - mariadb
    - redis
    - ctfd
    - nginx
  post_tasks:
    - name: Start CTFd with Docker Compose
      command: docker compose up -d
      args:
        chdir: /opt/ctfd
```

### Exercise 04 Compliance

This structure ensures compliance with Exercise 04 requirements:
- **Role separation**: Each service has its own role
- **Modular design**: Roles can be reused and modified independently
- **Clear responsibilities**: Each role has a specific purpose
- **Maintainable code**: Easy to update individual components

## Automation Scripts

### `setup.sh` - Environment Setup
**Purpose**: Initial environment preparation and tool installation

**Usage**:
```bash
./scripts/setup.sh
```

**What it does**:
- Checks for required `.cloudrc` credentials
- Installs OpenStack CLI if missing
- Installs Terraform if missing
- Installs Ansible if missing
- Initializes Terraform working directory
- Provides setup completion confirmation

### `update-inventory.sh` - Inventory Management
**Purpose**: Quick inventory updates without full deployment

**Usage**:
```bash
./scripts/update-inventory.sh
```

**What it does**:
- Retrieves current floating IP from Terraform
- Updates Ansible inventory with correct IP address
- Maintains proper YAML format for inventory file
- Useful for IP changes or inventory corruption recovery

### `update-and-deploy.sh` - Complete Deployment
**Purpose**: Full infrastructure and application deployment pipeline

**Usage**:
```bash
./scripts/update-and-deploy.sh
```

**What it does**:
- Loads OpenStack credentials
- Checks and installs prerequisites (pip3, ansible)
- Deploys/updates Terraform infrastructure
- Retrieves and updates floating IP in inventory
- Runs role-based Ansible playbook
- Provides deployment completion status
- Displays access URL for CTFd platform

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

#### Ansible Inventory (`inventory/hosts.yml`)
```yaml
ctfd_servers:
  hosts:
    ctfd_server:
      ansible_host: 10.225.151.204
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/group_33_key
```

#### Docker Compose Configuration (`roles/ctfd/files/docker-compose.yml`)
```yaml
version: '3'
services:
  ctfd:
    image: ctfd/ctfd:latest
    restart: always
    ports: ["8000:8000"]
    environment:
      - DATABASE_URL=mysql+pymysql://ctfd:ctfd@db/ctfd
      - REDIS_URL=redis://cache:6379
      - SECRET_KEY=ctfd_secret_key_for_group_33
    depends_on: [db, cache]
  
  nginx:
    image: nginx:latest
    restart: always
    ports: ["80:80"]
    depends_on: [ctfd]
    
  db:
    image: mariadb:10.5
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=ctfd
      - MYSQL_USER=ctfd
      - MYSQL_PASSWORD=ctfd
      - MYSQL_DATABASE=ctfd
  
  cache:
    image: redis:4
    restart: always
```

#### Nginx Reverse Proxy (`roles/nginx/templates/nginx.conf`)
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
| **Floating IP not working** | Connection timeouts | Check security group rules and VM status |
| **Container restart loops** | CTFd keeps restarting | Check Docker logs: `docker logs ctfd-ctfd-1` |
| **Database connection errors** | "Connection refused" | Verify MariaDB container is running |
| **Role execution fails** | Ansible role errors | Check role tasks and file permissions |
| **Inventory not found** | Ansible connection errors | Run `./scripts/update-inventory.sh` |

### Diagnostic Commands

#### Infrastructure Diagnostics
```bash
# Check OpenStack resources
source .cloudrc
openstack server list
openstack floating ip list

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

#### Ansible Diagnostics
```bash
# Test connectivity
ansible ctfd_servers -i inventory/hosts.yml -m ping

# Check playbook syntax
ansible-playbook --syntax-check -i inventory/hosts.yml playbook.yml

# Run playbook in check mode
ansible-playbook --check -i inventory/hosts.yml playbook.yml
```

#### Network Diagnostics
```bash
# Test web access
curl -I http://10.225.151.204

# Check port bindings (from inside VM)
sudo netstat -tlnp | grep -E ':(80|8000)'
```

## Daily Operations

### Starting Up
```bash
# Complete deployment (recommended)
./scripts/update-and-deploy.sh

# Or step by step
./scripts/setup.sh                    # First time only
cd terraform/ && terraform apply      # Infrastructure
./scripts/update-inventory.sh         # Update inventory
cd ansible/ && ansible-playbook -i inventory/hosts.yml playbook.yml  # Applications
```

### Checking Status
```bash
# Infrastructure status
openstack server list

# Application status  
ssh -i ~/.ssh/group_33_key ubuntu@10.225.151.204
sudo docker ps

# Ansible connectivity
cd ansible/
ansible ctfd_servers -i inventory/hosts.yml -m ping
```

### Updating Configuration
```bash
# Update inventory after infrastructure changes
./scripts/update-inventory.sh

# Redeploy applications only
cd ansible/
ansible-playbook -i inventory/hosts.yml playbook.yml

# Update specific role
ansible-playbook -i inventory/hosts.yml playbook.yml --tags "nginx"
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

### Security Considerations
- SSH key-based authentication only
- Security group restricts access to required ports
- Database not exposed to external network
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
- **Role-Based Management**: Modular Ansible structure for maintainability

### Integration Points
- **Terraform → Ansible**: Floating IP passed automatically to inventory
- **OpenStack → SSH**: Automated key management and VM access
- **Docker → Nginx**: Container networking and reverse proxy setup
- **CI/CD Ready**: Scripts support automated deployment pipelines
- **Role Dependencies**: Proper execution order maintained by playbook

### Exercise 04 Integration
This project demonstrates the progression from Exercise 04:
- **Exercise 04**: Vagrant + Ansible roles for local development
- **Exercise 05**: OpenStack + Terraform + same Ansible roles for cloud deployment
- **Reusability**: Same role structure works across different environments
- **Consistency**: Identical service configuration regardless of platform

## Additional Notes

### Customization Options
- Modify `terraform.tfvars` for different VM sizes or configurations  
- Update individual role tasks in `roles/*/tasks/main.yml`
- Customize `docker-compose.yml` template for additional services
- Adjust security group rules in `security.tf` as needed
- Add new roles by creating new directories in `roles/`

### Backup Recommendations
- Export Terraform state: `terraform show > infrastructure-backup.txt`
- Backup CTFd data: Regular backup of `/opt/ctfd/CTFd/` directory
- Export challenges and users through CTFd admin interface
- Version control all configuration files
- Backup role configurations and playbooks

### Production Considerations
This setup is designed for educational use. For production:
- Implement proper SSL/TLS certificates
- Use secure secret management
- Configure proper database backups and monitoring
- Consider high availability and load balancing

### Development and Testing
- **Local Testing**: Use Exercise 04 setup with Vagrant for development
- **Cloud Testing**: Use this Exercise 05 setup for integration testing
- **Role Testing**: Test individual roles with `ansible-playbook --tags "role_name"`
- **Infrastructure Testing**: Use `terraform plan` before applying changes

---

**Project**: Exercise 05 - Infrastructure As Code  
**Course**: IKT114 - IT Orchestration  
**Institution**: University of Agder  
**Group**: 33

## Version History

- **v2.0**: Role-based Ansible structure (Exercise 04 compliant)
- **v1.0**: Initial monolithic deployment structure