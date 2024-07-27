packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


variable "proxmox_api_token_id" {
  type = string
  default = "packer@pam!packer"
}

variable "proxmox_api_token_secret" {
  type = string
  default = "PLACEHOLDER_API_SECRET"
}

variable "proxmox_api_url" {
  type = string
  default = "https://192.x.x.x:8006/api2/json"
}

variable "proxmox_node" {
  type = string
  default = "node1"
}

variable "proxmox_storage" {
  type = string
  default = "local-lvm"
}

variable "cpu_type" {
  type    = string
  default = "kvm64"
}

variable "cores" {
  type    = string
  default = "2"
}

variable "cloudinit_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "talos_version" {
  type    = string
  default = "v1.7.5"
}

variable "base_iso_file" {
  type    = string
  default = "local-lvm:iso/archlinux-2024.07.01-x86_64.iso"
}

locals {

  image = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.7.5/nocloud-amd64.raw.xz"

}

source "proxmox-iso" "talos" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  iso_file    = "${var.base_iso_file}"
  unmount_iso = true

  scsi_controller = "virtio-scsi-single"
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    type              = "scsi"
    storage_pool      = var.proxmox_storage
    format            = "raw"
    disk_size         = "1500M"
    io_thread         = true
    cache_mode        = "writethrough"
  }

  memory               = 2048
  vm_id                = "9900"
  cores                = var.cores
  cpu_type             = var.cpu_type
  sockets              = "1"
  ssh_username         = "root"
  ssh_password         = "packer"
  ssh_timeout          = "15m"
  qemu_agent            = true

  cloud_init              = true
  cloud_init_storage_pool = var.cloudinit_storage_pool

  template_name        = "talos-${var.talos_version}-cloud-init-template"
  template_description = "Talos ${var.talos_version} cloud-init, built on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"

  boot_wait = "25s"
  boot_command = [
    "<enter><wait2m>",
    "passwd<enter><wait>packer<enter><wait>packer<enter>"
  ]
}

build {
  sources = ["source.proxmox-iso.talos"]

  provisioner "shell" {
    inline = [
      "curl -s -L ${local.image} -o /tmp/talos.raw.zst",
      "zstd -d -c /tmp/talos.raw.zst | dd of=/dev/sda && sync",
    ]
  }
}