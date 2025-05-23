# Define outputs for the Terraform configuration

output "ctfd_server_ip" {
  description = "The floating IP address of the CTFd server"
  value       = openstack_networking_floatingip_v2.ctfd_floating_ip.address
}

output "network_name" {
  description = "The name of the created network"
  value       = openstack_networking_network_v2.group_network.name
}

output "subnet_name" {
  description = "The name of the created subnet"
  value       = openstack_networking_subnet_v2.group_subnet.name
}