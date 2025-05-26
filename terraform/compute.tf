# Create an explicit network port
resource "openstack_networking_port_v2" "ctfd_port" {
  network_id = openstack_networking_network_v2.group_network.id
  
  security_group_ids = [
    openstack_networking_secgroup_v2.ctfd_security_group.id
  ]
  
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.group_subnet.id
  }
}

# Create a VM for all services
resource "openstack_compute_instance_v2" "ctfd_server" {
  name            = "CTFd_Server_Group_${var.group_number}"
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.ssh_key_name

  network {
    port = openstack_networking_port_v2.ctfd_port.id
  }
}

# Create a floating IP
resource "openstack_networking_floatingip_v2" "ctfd_floating_ip" {
  pool = var.external_network
}

# Associate floating IP with server using the explicit port
resource "openstack_networking_floatingip_associate_v2" "ctfd_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.ctfd_floating_ip.address
  port_id     = openstack_networking_port_v2.ctfd_port.id
}