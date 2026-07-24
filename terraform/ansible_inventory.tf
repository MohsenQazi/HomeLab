resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts.ini"
  depends_on = [libvirt_domain.vm]
  file_permission      = "0644"
  directory_permission = "0755"

  content = <<EOT
[control_plane]
%{ for name, node in local.nodes ~}
%{ if name == "cp" ~}
${name} ansible_host=${node.ip}
%{ endif ~}
%{ endfor ~}

[workers]
%{ for name, node in local.nodes ~}
%{ if startswith(name, "worker") ~}
${name} ansible_host=${node.ip}
%{ endif ~}
%{ endfor ~}

[k8s_cluster:children]
control_plane
workers

[all:vars]
ansible_user=debian
ansible_become=true
EOT
}
