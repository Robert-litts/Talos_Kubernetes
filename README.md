## Build and Deploy a Talos Kubernetes cluster on Proxmox using Packer and Terraform

### Run the talos_deploy.sh script to automatically build a Talos VM Template with Packer, deploy the VMs, and then bootstrap Kubernetes using Terraform. 

Ensure you copy/rename & update variables in the below two locations!

```
cp tfvars.example terraform.tfvars
cp packer/example_local_pkrvars packer/local.pkrvars.hcl
```

Update the variables as required for your desired configuration

```
chmod +x talos_deploy.sh
./talos_deploy.sh
```

### Alternatively, complete the actions from the shell script manually

1. Create Talos VM Template either manually by creating/uploading [Talos Factory Image](https://factory.talos.dev/) ISO to proxmox (be sure to select no-cloud option with qemu-guest-agent) or utilize the Packer script found within the "packer" folder to build & create the template automatically.
    #### To use the Packer script, rename the example.pkrvars and edit the contents as required

    ```
    cp example.pkrvars local.pkrvars.hcl
    ```
    #### Within the packer directory, run the following:

    ```
    packer init -upgrade .
    packer validate -var-file="local.pkrvars.hcl" .
    packer build -var-file="local.pkrvars.hcl" .
    ```
    #### The output will automatically creat a VM Template (9900) in Proxmox from the provided Talos Factory Image

2. Copy & rename the terraform variables file and update as required to suite your environment and desired cluster state

    ```
    cp tfvars.example terraform.tfvars
    ```

    #### After all variables are updated, navigate to the terraform directory and run the following to initialize terraform, create Talos machine configuration, provision the VMs in proxmox, and bootstrap etcd

    ```
    terraform init
    terraform plan
    terraform apply

    ```

3. You should now have a working Talos kubernetes cluster. The "kubeconfig" and "talosconfig" files are saved in the _out directory. To verify your cluster is working, run the following:

    ```
    kubectl --kubeconfig ./_out/kubeconfig get nodes
    ```


Resources:
- https://olav.ninja/talos-cluster-on-proxmox-with-terraform
- https://surajremanan.com/posts/automating-talos-installation-on-proxmox-with-packer-and-terraform/
- https://github.com/c0depool/c0depool-iac
- https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
- https://registry.terraform.io/providers/siderolabs/talos/latest/docs
- https://www.talos.dev/v1.7/talos-guides/install/cloud-platforms/nocloud/
- https://factory.talos.dev/
- https://www.talos.dev/v1.7/talos-guides/install/virtualized-platforms/proxmox/
- https://www.talos.dev/v1.7/learn-more/talosctl/
- https://archlinux.org/download/