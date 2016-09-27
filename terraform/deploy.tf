module "idr-docker" {
  source = "./idr-docker"
  idr_environment = "idr"
  privileged = "${var.docker_privileged}"
}

variable "docker_privileged" {
  description = "Run Docker containers in privileged mode (required on some docker hosts)"
  default = false
}

variable "docker_ansible_vars" {
  description = "Ansible playbook command line variables"
  default = "-e idr_net_iface=net -e idr_environment=idr -e omero_selinux_setup=False -e idr_nginx_ssl_self_signed=True"
}

variable "local_parent_repodir" {
  description = "Path to the parent directory of all required repositories"
  default = "~/work"
}

# Run ansible once all containers are running
resource "null_resource" "ansible" {
  triggers {
    idr_container_ips = "${module.idr-docker.database_ip} ${module.idr-docker.omero_ip} ${module.idr-docker.gateway_ip}"
  }
  provisioner "local-exec" {
    command = "cd ${var.local_parent_repodir}/infrastructure/ansible && ansible-playbook -i ${var.local_parent_repodir}/idr-terraform/ansible-docker-inventory.py idr-playbooks/idr.yml ${var.docker_ansible_vars}"
  }
}
