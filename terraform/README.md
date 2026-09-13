### Hypervisor Requirments (Tested on debian 13.6)

- Tools/Packages
    `qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virtinst bridge-utils`

- To create VMs with non-root user
    `sudo usermod -aG libvirt,kvm $USER`

- And prune libvirt's default network and pool.

### Local Registry
To avoid issues caused by access restrictions, it is good practice to pre-pull images and store them locally.

 1. Download images to /opt/terraform-providers via `proxychains`, `export http_proxy=....` or any other solution you may know.
```
terraform providers mirror /opt/terraform-providers
```
 2. ~/.terraformrc
```
provider_installation {                                                   
  filesystem_mirror {                                                     
     path = "/opt/terraform-providers"                                     
  }                                                                       
}
```
