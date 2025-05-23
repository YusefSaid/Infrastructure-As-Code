# Infrastructure as Code with Terraform and Ansible
Test comment -- 
This project demonstrates how to use Infrastructure as Code (IaC) principles with Terraform and Ansible to deploy a CTFd platform on OpenStack.

## Prerequisites

- OpenStack credentials
- SSH key pair
- Terraform
- Ansible

## Setup

1. Clone this repository
2. Create a `.cloudrc` file with your OpenStack credentials
3. Run the setup script: `./scripts/setup.sh`
4. Update `terraform/terraform.tfvars` with your group number and SSH key name
5. Deploy the infrastructure: `./scripts/deploy.sh`

## Architecture

The infrastructure consists of:
- Network, subnet, and router in OpenStack
- A single VM running:
  - CTFd application
  - Nginx as a reverse proxy
  - MariaDB as the database
  - Redis for caching

All components are deployed using Docker Compose for easy management.

## File Structure

- `terraform/`: Terraform configuration files
- `ansible/`: Ansible playbooks and roles
- `scripts/`: Utility scripts for setup and deployment

## Usage

After deployment, you can access the CTFd platform at the floating IP address of the VM.