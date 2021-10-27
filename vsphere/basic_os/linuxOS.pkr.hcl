variable "vcenter_server" { type = string }
variable "vcenter_username" { type = string }
variable "vcenter_password" { type = string }
variable "vcenter_datacenter" { type = string }
variable "vcenter_cluster" { type = string }
variable "vcenter_host" { type = string }
variable "vcenter_folder" { type = string }
variable "vcenter_datastore" { type = string }
variable "vcenter_network" { type = string }
variable "iso_path" { type = string }
variable "vm_name" { type = string }
variable "vm_notes" { type = string }
variable "vm_guest_os_type" { type = string }
variable "vm_guestinfo_metadata" { type = string }
variable "ssh_username" { type = string }
variable "ssh_password" { type = string }
variable "ssh_keys" { type = string }
variable "boot_command" { type = list(string) }
variable "packer_websrv_bindip" { type = string }


source "vsphere-iso" "vm_template" {
  vcenter_server = "${var.vcenter_server}"
  username       = "${var.vcenter_username}"
  password       = "${var.vcenter_password}"
  datacenter     = "${var.vcenter_datacenter}"
  #host           = "${var.vcenter_host}"

  # Location Configuration
  vm_name   = "${var.vm_name}_CLOUDINIT"
  cluster   = "${var.vcenter_cluster}"
  folder    = "${var.vcenter_folder}"
  datastore = "${var.vcenter_datastore}"

  # Hardware Configuration
  CPUs            = 2
  cpu_cores       = 2
  RAM             = 2048
  RAM_reserve_all = false

  # Run Configuration
  boot_order = "disk,cdrom"
  iso_paths = ["${var.iso_path}"]

  # Create Configuration
  notes                = format("${var.vm_notes} - %v", timestamp())
  guest_os_type        = "${var.vm_guest_os_type}"
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 16384
    disk_thin_provisioned = true
  }
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "vmxnet3"
  }

  # Extra Configuration Parameters
  #configuration_parameters = {
  #  "guestinfo.metadata"          = base64encode("${var.vm_guestinfo_metadata}")
  #  "guestinfo.metadata.encoding" = "base64"
  #}

  # Boot Configuration
  boot_wait      = "5s"
  boot_command   = "${var.boot_command}"
  http_ip        = "${var.packer_websrv_bindip}"
  http_directory = "${path.root}/http"
  http_port_min  = 8000
  http_port_max  = 8009

  # General Configuration
  create_snapshot     = "false"
  convert_to_template = "true"

  # Communicator configuration
  communicator           = "ssh"
  ssh_username           = "${var.ssh_username}"
  ssh_password           = "${var.ssh_password}"
  ssh_timeout            = "30m"
  ssh_handshake_attempts = 10

}

build {
  sources = ["source.vsphere-iso.vm_template"]

  provisioner "shell" {
    execute_command = "sudo -E bash '{{ .Path }}'"
    scripts         = ["script_cloudinit.sh"]
  }
}
