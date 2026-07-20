resource "libvirt_pool" "k8s" {
  name = "k8s"
  type = "dir"
  target {
    path = "/opt/libvirt-pool/k8s"
  }
}

resource "libvirt_network" "k8s" {
  name      = "k8s"
  mode      = "nat"
  domain    = "k8s.local"
  addresses = ["192.168.122.0/24"]

  dhcp {
    enabled = false
  }

  dns {
    enabled           = true
    local_only        = true
  }

  autostart = true
}
