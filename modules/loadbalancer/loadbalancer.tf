variable "count" {}
variable "ssh_fingerprint" {}

resource "digitalocean_droplet" "loadbalancer" {
  count = "${var.count}"
  image = "ubuntu-16-04-x64"
  name = "loadbalancer-${count.index}"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
}

output "public_ips" {
  value = ["${digitalocean_droplet.loadbalancer.*.ipv4_address}"]
}

output "private_ips" {
  value = ["${digitalocean_droplet.loadbalancer.*.ipv4_address_private}"]
}
