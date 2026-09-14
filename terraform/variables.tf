variable "libvirt_uri" {
  default = "qemu:///system"
}

variable "base_image" {
  default = "/var/lib/libvirt/k8s/debian-12-generic-amd64.qcow2"
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  default = ".........."
}

variable "vm_memory" {
  default = 2048
}

variable "vm_vcpu" {
  default = 2
}

variable "vm_disk_size_gb" {
  type    = number
  default = 30
}

variable "network_cidr" {
  description = "CIDR block for the libvirt NAT network"
  type        = string
  default     = "192.168.122.0/24"
}

variable "dns_secondary" {
  description = "Secondary DNS resolver address"
  type        = string
  default     = "1.1.1.1"
}

variable "apt_cache_port" {
  description = "Port apt-cacher-ng listens on"
  type        = number
  default     = 3142
}
