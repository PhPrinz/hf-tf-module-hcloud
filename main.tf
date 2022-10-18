variable "hcloud_token" {}
variable "public_key" {}
variable "image" {}
variable "name" {}
variable "server_type" {}
variable "location" {}
variable "runcmd" {}

#Configure the Hetzner Cloud Provider
provider "hcloud" {
  version = "= 1.10"
  token = "${var.hcloud_token}"
}

# Create a new SSH key
resource "hcloud_ssh_key" "key" {
  name = "${var.name}-key"
  public_key = "${var.public_key}"
}

# Create a new server running debian
resource "hcloud_server" "node1" {
  name = "${var.name}"
  image = "${var.image}"
  location = "${var.location}"
  server_type = "${var.server_type}"
  ssh_keys = ["${var.name}-key","ebartz"]
  #user_data = "#cloud-config\nruncmd:\n- ${var.runcmd}\n"
  user_data = "templatefile('cloud-config.cfg', {runcmd = ${var.runcmd}})"
}

output "private_ip" {
  value = "${hcloud_server.node1.ipv4_address}"
}

output "public_ip" {
  value = "${hcloud_server.node1.ipv4_address}"
}

output "hostname" {
  value = "${hcloud_server.node1.name}"
}
