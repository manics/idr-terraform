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
  default = "m1.large"
}

variable "database_db_volume_source" {
  description = "UUID of the database-db volume to be copied"
}

variable "omero_data_volume_source" {
  description = "UUID of the omero-data volume to be copied"
}


output "list_of_ips" {
  value = "${openstack_compute_instance_v2.database.access_ip_v4} ${openstack_compute_instance_v2.omero.access_ip_v4} ${openstack_compute_instance_v2.dockermanager.access_ip_v4}"
}
#${openstack_compute_instance_v2.dockerworker.access_ip_v4}

output "floating_ip" {
  value = "${openstack_compute_floatingip_v2.floating_ip.address}"
}
