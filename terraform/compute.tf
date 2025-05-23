# Create a VM for all services
resource "openstack_compute_instance_v2" "ctfd_server" {
  name            = "CTFd_Server_Group_${var.group_number}"
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.ssh_key_name

  network {
    uuid = openstack_networking_network_v2.group_network.id
  }

  security_groups = [
    openstack_networking_secgroup_v2.ctfd_security_group.name
  ]
}

# Create a floating IP
resource "openstack_networking_floatingip_v2" "ctfd_floating_ip" {
  pool = var.external_network
}

# Associate floating IP with server using the correct resource type
resource "openstack_networking_floatingip_associate_v2" "ctfd_floating_ip_association" {
  floating_ip = openstack_networking_floatingip_v2.ctfd_floating_ip.address
  port_id     = openstack_compute_instance_v2.ctfd_server.network.0.port
}