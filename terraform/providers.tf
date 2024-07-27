terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    
        talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}

provider "proxmox" {

  pm_api_url = var.pm_api_url

  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = var.pm_api_token_id

  pm_api_token_secret = var.pm_api_token_secret

  pm_tls_insecure = true

  pm_timeout=2000
  pm_parallel = 2
}
