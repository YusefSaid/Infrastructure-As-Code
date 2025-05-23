terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  # Authentication information is sourced from environment variables
  # from the .cloudrc file
}