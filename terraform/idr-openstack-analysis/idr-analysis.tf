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

variable "vm_flavor" {
  default = "m1.large"
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


resource "openstack_blockstorage_volume_v2" "database_volume" {
  name = "${var.idr_environment}-database-db"
  size = 100
  # TODO: Snapshot or source_vol
  #snapshot_id =
  source_vol_id = "${var.database_db_volume_source}"
}

resource "openstack_blockstorage_volume_v2" "omero_volume" {
  name = "${var.idr_environment}-omero-data"
  size = 500
  # TODO: Snapshot or source_vol
  #snapshot_id =
  source_vol_id = "${var.omero_data_volume_source}"
}


resource "openstack_compute_floatingip_v2" "floating_ip" {
  pool = "external_network"
}


# There's a bug(?) which means multiple volumes may be attached in the wrong
# order, so for now create two VMs instead of combining database and omero

resource "openstack_compute_instance_v2" "database" {
  name = "${var.idr_environment}-database"
  image_name = "${var.vm_image}"
  flavor_name = "${var.vm_flavor}"
  key_pair = "${var.vm_keyname}"
  security_groups = ["default"]

  stop_before_destroy = true

  metadata {
    # Ansible groups
    groups = "${var.idr_environment}-database-hosts,database-hosts,${var.idr_environment}-hosts"
    # Is hostname needed by Ansible?
    hostname = "${var.idr_environment}-database"
  }

  volume {
    volume_id = "${openstack_blockstorage_volume_v2.database_volume.id}"
  }
}


resource "openstack_compute_instance_v2" "omero" {
  name = "${var.idr_environment}-omero"
  image_name = "${var.vm_image}"
  flavor_name = "${var.vm_flavor}"
  key_pair = "${var.vm_keyname}"
  security_groups = ["default"]

  stop_before_destroy = true

  metadata {
    # Ansible groups
    groups = "${var.idr_environment}-omero-hosts,omero-hosts,${var.idr_environment}-hosts"
    # Is hostname needed by Ansible?
    hostname = "${var.idr_environment}-omero"
  }

#  network {
#    name = "${var.idr_environment}-network"
#    access_network = true
#  }

#  floating_ip = "${openstack_compute_floatingip_v2.floating_ip.address}"

  volume {
    volume_id = "${openstack_blockstorage_volume_v2.omero_volume.id}"
  }
}


resource "openstack_compute_instance_v2" "dockermanager" {
  name = "${var.idr_environment}-docker"
  image_name = "${var.vm_image}"
  flavor_name = "${var.docker_vm_flavor}"
  key_pair = "${var.vm_keyname}"
  security_groups = ["default"]

  stop_before_destroy = true

  metadata {
    # Ansible groups
    groups = "${var.idr_environment}-dockermanager-hosts,dockermanager-hosts,${var.idr_environment}-hosts"
    # Is hostname needed by Ansible?
    hostname = "${var.idr_environment}-docker"
  }

  floating_ip = "${openstack_compute_floatingip_v2.floating_ip.address}"
}


resource "openstack_compute_instance_v2" "dockerworker" {
  name = "${var.idr_environment}-dockerworker"
  image_name = "${var.vm_image}"
  flavor_name = "${var.docker_vm_flavor}"
  key_pair = "${var.vm_keyname}"
  security_groups = ["default"]
  count = 1

  #stop_before_destroy = true

  metadata {
    # Ansible groups
    groups = "${var.idr_environment}-dockerworker-hosts,dockerworker-hosts,${var.idr_environment}-hosts"
    # Is hostname needed by Ansible?
    hostname = "${var.idr_environment}-dockerworker"
  }
}


output "list_of_ips" {
  value = "${openstack_compute_instance_v2.database.access_ip_v4} ${openstack_compute_instance_v2.omero.access_ip_v4} ${openstack_compute_instance_v2.dockermanager.access_ip_v4} ${openstack_compute_instance_v2.dockerworker.access_ip_v4}"
}

output "floating_ip" {
  value = "${openstack_compute_floatingip_v2.floating_ip.address}"
}
