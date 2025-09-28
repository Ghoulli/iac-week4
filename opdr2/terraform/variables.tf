variable "esxi_hostname" { type = string }
variable "esxi_username" { type = string }
variable "esxi_password" { type = string }
variable "esxi_hostssl" {
  description = "ESXi host SSL port"
  type        = number
}

variable "esxi_hostport" {
  description = "ESXi host SSH port"
  type        = number
}

variable "ovf_source" {
  description = "URL to Ubuntu 24.04 OVA/OVF"
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.ova"
}

variable "vm_name"    { type = string }
variable "datastore"  { type = string }
variable "network"    { type = string }
variable "vm_cpu"     { type = number }
variable "vm_ram_mb"  { type = number }
variable "vm_disk_gb" { type = number }

variable "ssh_pubkey_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

# Output-bestand voor inventory
variable "inventory_path" {
  type    = string
  default = "./inventory.ini"
}
