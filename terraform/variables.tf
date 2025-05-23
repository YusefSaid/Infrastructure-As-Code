# Define variables for the Terraform configuration

variable "group_number" {
  description = "Your lab group number"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key in OpenStack"
  type        = string
}

variable "image_name" {
  description = "Name of the image to use for VMs"
  type        = string
  default     = "ubuntu-noble"
}

variable "flavor_name" {
  description = "Name of the flavor to use for VMs"
  type        = string
  default     = "medium"
}

variable "external_network" {
  description = "Name of the external network"
  type        = string
  default     = "public"
}