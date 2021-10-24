variable "vcenter_server" {type = string}
variable "vcenter_username" {type = string}
variable "vcenter_password" {type = string}
variable "vcenter_datacenter" {type = string}
variable "vcenter_cluster" {type = string}
variable "vcenter_host" {type = string}
variable "vcenter_folder" {type = string}
variable "vcenter_datastore" {type = string}
variable "vcenter_network" {type = string}
variable "iso_path" {type = string}
variable "vm_name" {type = string}
variable "vm_notes" {type = string}
variable "vm_guest_os_type" {type = string}
variable "vm_guestinfo_metadata" {type = string}
variable "ssh_username" {type = string}
variable "ssh_password" {type = string}
variable "ssh_keys" {type = string}
variable "boot_command" {}
variable "local_websrv_ip" {type = string}

source "vsphere-iso" "vm_template" {
  CPUs            = 2
  RAM             = 2048
  RAM_reserve_all = false
  boot_command    = "${var.boot_command}"
  boot_order      = "disk,cdrom"
  boot_wait       = "5s"
  cluster         = "${var.vcenter_cluster}"
  communicator    = "ssh"
#  configuration_parameters = {
#    "guestinfo.metadata" = base64encode("${var.vm_guestinfo_metadata}")
#    "guestinfo.metadata.encoding" = "base64"
#  }
  convert_to_template  = "true"
  cpu_cores            = 2
  create_snapshot      = "false"
  datacenter           = "${var.vcenter_datacenter}"
  datastore            = "${var.vcenter_datastore}"
  disk_controller_type = ["pvscsi"] 
  folder               = "${var.vcenter_folder}"
  guest_os_type        = "${var.vm_guest_os_type}"
  host                 = "${var.vcenter_host}"
  http_directory       = "${path.root}/http"
  http_ip              = "${var.local_websrv_ip}"
  http_port_max        = 8009
  http_port_min        = 8000
  insecure_connection  = "true"
  iso_paths            = ["${var.iso_path}"]
  network_adapters {
    network      = "${var.vcenter_network}"
    network_card = "vmxnet3"
  }
  notes                  = "${var.vm_notes}"
  password               = "${var.vcenter_password}"
  ssh_handshake_attempts = 10
  ssh_password           = "${var.ssh_password}"
  ssh_timeout            = "30m"
  ssh_username           = "${var.ssh_username}"
  storage {
    disk_size             = 16384
    disk_thin_provisioned = true
  }
  username       = "${var.vcenter_username}"
  vcenter_server = "${var.vcenter_server}"
  vm_name        = "${var.vm_name}"
}

build {
  sources = ["source.vsphere-iso.vm_template"]

  provisioner "shell" {
    execute_command = "sudo -E bash '{{ .Path }}'"
    scripts         = ["script.sh"]
  }

}