# Variables
variable "idr_environment" {
  description = "IDR environment/deployment"
}

variable "vm_image" {
  default = "CentOS 7 1607"
}

variable "vm_keyname" {
  description = "SSH key"
}

variable "omero_vm_flavor" {
  default = "m2.large"
}

variable "docker_vm_flavor" {
  default = "m2.xxlarge"
}

variable "database_db_volume_source" {
  description = "UUID of the database-db volume to be copied"
}

variable "omero_data_volume_source" {
  description = "UUID of the omero-data volume to be copied"
}

# Configure the OpenStack Provider
#provider "openstack" {
#    user_name  = "admin"
#    tenant_name = "admin"
#    password  = "pwd"
#    auth_url  = "http://myauthurl:5000/v2.0"
#}

# https://www.terraform.io/docs/providers/openstack/r/compute_instance_v2.html


resource "openstack_blockstorage_volume_v2" "database-volume" {
  name = "${var.idr_environment}-omerosingle-db"
  size = 100
  # TODO: Snapshot or source_vol
  #snapshot_id =
  source_vol_id = "${var.database_db_volume_source}"
}

resource "openstack_blockstorage_volume_v2" "omero-volume" {
  name = "${var.idr_environment}-omerosingle-data"
  size = 500
  # TODO: Snapshot or source_vol
  #snapshot_id =
  source_vol_id = "${var.omero_data_volume_source}"
}

resource "openstack_compute_floatingip_v2" "omerosingle-ip" {
  pool = "external_network"
}

# Combined OMERO.server and Database VM
resource "openstack_compute_instance_v2" "omerosingle" {
  name = "${var.idr_environment}-omerosingle"
  image_name = "${var.vm_image}"
  flavor_name = "${var.omero_vm_flavor}"
  key_pair = "${var.vm_keyname}"
  security_groups = ["default"]

  stop_before_destroy = true

  metadata {
    # Ansible groups
    groups = "${var.idr_environment}-database-hosts,database-hosts,${var.idr_environment}-omero-hosts,omero-hosts,${var.idr_environment}-hosts"
    # Is hostname needed by Ansible?
    hostname = "${var.idr_environment}-omerosingle"
  }

#  network {
#    name = "${var.idr_environment}-network"
#    access_network = true
#  }

  floating_ip = "${openstack_compute_floatingip_v2.omerosingle-ip.address}"

# Setting `device` seems to break something, so instead just hope the volumes
# are assigned in order
  volume {
    volume_id = "${openstack_blockstorage_volume_v2.database-volume.id}"
    #device = "/dev/vdb"
  }
  volume {
    volume_id = "${openstack_blockstorage_volume_v2.omero-volume.id}"
    #device = "/dev/vdc"
  }


#  connection {
#    user = "centos"
#    key_file = ""
#    host = "${self.access_ip_v4}"
#  }
}

output "list_of_ips" {
  value = "${openstack_compute_instance_v2.omerosingle.access_ip_v4}"
}
