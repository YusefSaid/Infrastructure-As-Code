# Create Network
resource "openstack_networking_network_v2" "group_network" {
  name           = "Group_${var.group_number}_Network"
  admin_state_up = "true"
}

# Create Subnet
resource "openstack_networking_subnet_v2" "group_subnet" {
  name            = "Group_${var.group_number}_Subnet"
  network_id      = openstack_networking_network_v2.group_network.id
  cidr            = "192.168.1.0/24"
  ip_version      = 4
  dns_nameservers = ["158.37.218.20", "158.37.218.21", "158.37.242.20", "158.37.242.21", "128.39.54.10"]
  gateway_ip      = "192.168.1.1"
}

# Fetch the external network
data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

# Create Router
resource "openstack_networking_router_v2" "group_router" {
  name                = "Group_${var.group_number}_Router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

# Create Router Interface
resource "openstack_networking_router_interface_v2" "group_router_interface" {
  router_id = openstack_networking_router_v2.group_router.id
  subnet_id = openstack_networking_subnet_v2.group_subnet.id
}