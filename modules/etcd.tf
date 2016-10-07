variable "count" {}
variable "ssh_fingerprint" {}

resource "digitalocean_tag" "etcd" {
  name = "etcd"
}

resource "digitalocean_droplet" "etcd" {
  count = "${var.count}"
  image = "ubuntu-16-04-x64"
  name = "test-etcd-${count.index}"
  region = "sfo1"
  size = "512mb"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  tags = ["${digitalocean_tag.etcd.name}"]

  /* provisioner "local-exec" { */
  /*   command = "echo hi >> ~/test.txt" */
  /* } */
}

output "public_ips" {
  value = ["${digitalocean_droplet.etcd.*.ipv4_address}"]
}
