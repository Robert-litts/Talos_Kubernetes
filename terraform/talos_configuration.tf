resource "talos_machine_secrets" "machine_secrets" {
    talos_version = var.talos_version
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = var.talos_cp_ip_addrs
  nodes                = concat(var.talos_cp_ip_addrs, var.talos_worker_ip_addrs)
}

data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_ip_addrs[0]}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  count                       = length(var.talos_cp_ip_addrs)
  depends_on                  = [ proxmox_vm_qemu.talos_control_plane ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = var.talos_cp_ip_addrs[count.index]
}

data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_ip_addrs[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  count                       = length(var.talos_worker_ip_addrs)
  depends_on                  = [ proxmox_vm_qemu.talos_worker ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  node                        = var.talos_worker_ip_addrs[count.index]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_ip_addrs[0]
}

resource "time_sleep" "wait_for_talos_api" {
  depends_on = [talos_machine_bootstrap.bootstrap]
  create_duration = "60s"
}

data "talos_cluster_health" "health" {
  depends_on           = [ time_sleep.wait_for_talos_api, talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply ]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = var.talos_cp_ip_addrs
  worker_nodes         = var.talos_worker_ip_addrs
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
  
}

resource "time_sleep" "wait_for_kubeconfig" {
  depends_on = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  create_duration = "60s"
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_ip_addrs[0]
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.talosconfig.talos_config
  filename = "${path.module}/../_out/talosconfig"
}

resource "local_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = "${path.module}/../_out/kubeconfig"
}


output "talosconfig" {
  value = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

