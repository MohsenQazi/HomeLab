### Requirments (Tested on debian trixie)                                   
                                                                              
- hypervisor
    `qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virtinst bridge-utils`

- To create VMs with non-root user
    `sudo usermod -aG libvirt,kvm $USER`

- And prune libvirt's default network and pool.

### Set local registry for Images
In the case of access restrictions, it is a good idea to have images locally:
1. Download images to /opt/terraform-providers
```
proxychains terraform providers mirror /opt/terraform-providers
```
2. ~/.terraformrc
```
provider_installation {                                                   
  filesystem_mirror {                                                     
     path = "/opt/terraform-providers"                                     
  }                                                                       
}
```
