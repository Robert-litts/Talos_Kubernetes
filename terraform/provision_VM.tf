resource "proxmox_vm_qemu" "talos_control_plane" {
  count = length(var.talos_cp_ip_addrs)
  name = "talos-controlplane-${count.index + 1}" 
  onboot = true
  target_node = var.proxmox_host_1
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4048

  numa = true

  cloudinit_cdrom_storage = var.storage
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  boot = "order=scsi0;ide3" 

  disks {
        scsi {
            scsi0 {
                disk {
                  storage = var.storage
                  size = 10
                }
            }
        }
  }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = var.vlan
  }

  ipconfig0 = "ip=${element(var.talos_cp_ip_addrs, count.index)}/24,gw=${var.default_gateway}"
  nameserver = var.nameserver
}


resource "proxmox_vm_qemu" "talos_worker" {
  count = length(var.talos_worker_ip_addrs)
  name = "talos-worker-${count.index + 1}" 
  onboot = true
  target_node = var.proxmox_host_1
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4048

  numa = true

  cloudinit_cdrom_storage = var.storage
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  boot = "order=scsi0;ide3" 

  disks {
        scsi {
            scsi0 {
                disk {
                  storage = var.storage
                  size = 10
                }
            }
        }
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    tag = var.vlan
  }
  
  ipconfig0 = "ip=${element(var.talos_worker_ip_addrs, count.index)}/24,gw=${var.default_gateway}"
  nameserver = var.nameserver

}

