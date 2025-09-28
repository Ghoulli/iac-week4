terraform {
  required_version = ">= 1.5.0"
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_username = var.esxi_username
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_password = var.esxi_password
}

locals {
  ssh_pubkey = trimspace(file(var.ssh_pubkey_path))

  cloud_init_user_data = <<-YAML
    #cloud-config
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${local.ssh_pubkey}
    package_update: true
    packages:
      - open-vm-tools
    runcmd:
      - systemctl enable --now open-vm-tools || true
    YAML
}

resource "esxi_guest" "ubuntu" {
  guest_name     = var.vm_name
  disk_store     = var.datastore
  ovf_source     = var.ovf_source

  numvcpus       = var.vm_cpu
  memsize        = var.vm_ram_mb
  boot_disk_size = var.vm_disk_gb

  network_interfaces {
    virtual_network = var.network
    # nic_type = "vmxnet3"
  }

  # Wachten tot VMware Tools een IP heeft doorgegeven
  guest_startup_timeout = 300

  # Cloud-init via VMware guestinfo (base64 vereist bij encoding=base64)
  guestinfo = {
    "userdata"          = base64encode(local.cloud_init_user_data)
    "userdata.encoding" = "base64"
  }
}

# Automatisch inventorybestand genereren met app_name="demoapp"
resource "local_file" "inventory" {
  filename = var.inventory_path
  content  = <<-EOT
    [ubuntu]
    ${esxi_guest.ubuntu.ip_address} app_name="demoapp"
  EOT
  depends_on = [esxi_guest.ubuntu]
}

output "vm_name"                { value = esxi_guest.ubuntu.guest_name }
output "vm_ip"                  { value = esxi_guest.ubuntu.ip_address } # via DHCP + VMware Tools
output "inventory_written_to"   { value = local_file.inventory.filename }
