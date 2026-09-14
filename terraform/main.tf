locals {
  gateway_ip     = cidrhost(var.network_cidr, 1)
  network_prefix = split("/", var.network_cidr)[1]

  nodes = {
    cp = {
      ip = cidrhost(var.network_cidr, 10)
      mac    = "52:54:00:00:00:10"
      memory = 2048
      vcpu   = 2
      disk   = 20
      secondary   = 40
    }
    worker1 = {
      ip = cidrhost(var.network_cidr, 11)
      mac    = "52:54:00:00:00:11"
      memory = 4096
      vcpu   = 2
      disk   = 20
      secondary   = 50
    }
    worker2 = {
      ip = cidrhost(var.network_cidr, 12)
      mac    = "52:54:00:00:00:12"
      memory = 4096
      vcpu   = 2
      disk   = 20
      secondary   = 50
    }
  }
}

resource "libvirt_volume" "base" {
  name   = "base-image"
  pool   = libvirt_pool.k8s.name
  source = var.base_image
  format = "qcow2"
}

resource "libvirt_volume" "disk" {
  for_each       = local.nodes

  name           = "${each.key}.qcow2"
  pool           = libvirt_pool.k8s.name
  base_volume_id = libvirt_volume.base.id
  size = each.value.disk * 1024 * 1024 * 1024
}

resource "libvirt_volume" "data_disk" {
  for_each = local.nodes

  name = "${each.key}-data.qcow2"
  pool = libvirt_pool.k8s.name
  format = "qcow2"
  size = each.value.secondary * 1024 * 1024 * 1024
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = local.nodes

  name = "${each.key}-cloudinit.iso"
  pool = libvirt_pool.k8s.name

  user_data = templatefile("${path.module}/cloud_init.cfg", {
    hostname       = each.key
    ssh_key        = var.ssh_public_key
    apt_cache_host = local.gateway_ip
    apt_cache_port = var.apt_cache_port
  })

  network_config = templatefile("${path.module}/network_config.cfg", {
    ip             = each.value.ip
    mac            = each.value.mac
    prefix         = local.network_prefix
    gateway        = local.gateway_ip
    dns_secondary  = var.dns_secondary
  })
}

resource "libvirt_domain" "vm" {
  for_each = local.nodes

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.vcpu
  autostart = true
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.disk[each.key].id
  }

  disk {
    volume_id = libvirt_volume.data_disk[each.key].id
  }

  network_interface {
    network_name   = libvirt_network.k8s.name
    mac            = each.value.mac
    wait_for_lease = false # we use static IP and no need terraform wait for libvirt DHCP
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    autoport = true
  }
}
