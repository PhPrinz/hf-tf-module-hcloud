variable "hcloud_token" {}
variable "public_key" {}
variable "image" {}
variable "name" {}
variable "server_type" {}
variable "location" {}
variable "cloud-config" {}
variable "runcmd" {
  default = "echo ' '"
}
variable "ide" {
  default = false
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.cfg")}"
  vars = {
    runcmd = "${var.runcmd}"
  }
}

data "template_file" "cloud-config-ide" {
  template = "${file("${path.module}/cloud-config-ide.cfg")}"
  vars = {
    runcmd = "${var.runcmd}"
  }
}

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
  #user_data = "${var.ide ? "#cloud-config\nruncmd:\n- echo 'IDE true' > /root/ide-true.txt\n" : "#cloud-config\nruncmd:\n- ${var.runcmd}\n"}"
  #user_data = "templatefile('cloud-config.cfg', {runcmd = ${var.runcmd}})"
  #user_data = "${var.ide ? "${data.template_file.cloud-config-ide.rendered}" : "${data.template_file.cloud-config.rendered}"}"
  user_data = "${var.cloud-config}"
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
