#

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
    groups = "${var.idr_environment}-omero-hosts,omero-hosts,${var.idr_environment}-hosts,${var.idr_environment}-${var.idr_nfs_group}"
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
  name = "${var.idr_environment}-dockermanager"
  image_name = "${var.vm_image}"
  flavor_name = "${var.docker_vm_flavor}"
  key_pair = "${var.vm_keyname}"
  security_groups = ["default"]

  stop_before_destroy = true

  metadata {
    # Ansible groups
    groups = "${var.idr_environment}-dockermanager-hosts,${var.idr_environment}-docker-hosts,${var.idr_environment}-hosts,${var.idr_environment}-data-hosts"
  }

  floating_ip = "${openstack_compute_floatingip_v2.floating_ip.address}"

  volume {
    volume_id = "${openstack_blockstorage_volume_v2.jupyter_volume.id}"
  }
}

/*
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
    groups = "${var.idr_environment}-dockerworker-hosts,${var.idr_environment}-docker-hosts,${var.idr_environment}-hosts"
    # Is hostname needed by Ansible?
    hostname = "${var.idr_environment}-dockerworker"
  }
}
*/
