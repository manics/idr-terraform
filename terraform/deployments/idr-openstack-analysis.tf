variable "vm_keyname" {
  description = "SSH key"
}

module "idr" {
  source = "../idr-openstack-analysis"
  idr_environment = "analysis"
  vm_keyname = "${var.vm_keyname}"
  idr_nfs_group = "uod-nfs"

  database_db_volume_source = "c3a16065-08d2-4401-95e5-ca71c4305cc6"
  omero_data_volume_source= "f383e3b3-3382-4573-9526-aa8b32a28aff"
}

# idr-playbooks/utils-reset-public-password.yml sets the password for
# omero user 52 to `public`
module "idr-ansible" {
  source = "../idr-ansible"
  delay = 5
  ansible_vars = "-u centos -e idr_environment=analysis -e idr_nginx_ssl_self_signed=True -e omero_public_userid=52 -e omero_public_hash='yypDVLMt42syD+8x2ugFUQ=='"
  ansible_workdir = "../../ansible"
  #ansible_inventory = "inventory/openstack.py"
  ansible_inventory = "inventory/openstack-private.py"
  ansible_additional_playbooks = "idr-playbooks/utils-reset-public-password.yml"
  ansible_ssh = "'-o ProxyCommand=\\\"ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -W %h:%p -q centos@${module.idr.floating_ip}\\\" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'"
  wait_for = "${module.idr.list_of_ips}"
}
