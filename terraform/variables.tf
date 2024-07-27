
variable "cluster_name" {
  type    = string
  default = "homelab-talos"
}

variable "default_gateway" {
  type    = string
}

variable "nameserver" {
  type    = string
}

variable "storage" {
  type = string
  default = "local-lvm"
}

variable "talos_cp_ip_addrs" {
  type        = list(string)
  description = "List of IP addresses for Talos control plane nodes"
}

variable "talos_worker_ip_addrs" {
  type        = list(string)
  description = "List of IP addresses for Talos worker nodes"
}


variable "talos_version" {
    default = "v1.7.5"
}


variable "proxmox_host_1" {
  type    = string
}

#if using proxmox cluster and want to deploy across nodes
variable "proxmox_host_2" {
  type    = string
}

variable "template_name" {
    type = string
}

variable "pm_api_url" {
  type = string
}

variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type = string
}

variable "vlan" {
  type = number
  default = 1
}
