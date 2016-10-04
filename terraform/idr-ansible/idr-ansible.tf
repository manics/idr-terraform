variable "wait_for" {
  description = "Wait for this variable to be populated"
  default = ""
}

variable "delay" {
  description = "Wait this number of seconds before runnign ansible"
  default = 0
}

variable "ansible_vars" {
  description = "Ansible playbook command line variables"
  default = ""
}

variable "ansible_vars2" {
  description = "More Ansible playbook command line variables"
  default = ""
}

variable "ansible_workdir" {
  description = "Change to this directory before running Ansible"
}

variable "ansible_inventory" {
  description = "Ansible inventory file or path"
}

variable "ansible_playbooks" {
  description = "Ansible playbook(s)"
}

variable "ansible_ssh" {
  description = "Ansible ssh arguments"
  default = ""
}

# Run ansible once all containers are running
resource "null_resource" "ansible" {
  triggers {
    wait_for = "${var.wait_for}"
  }
  provisioner "local-exec" {
    command = "sleep ${var.delay} && cd ${var.ansible_workdir} && ansible-playbook -i ${var.ansible_inventory} -e ansible_ssh_common_args=\"${var.ansible_ssh}\" ${var.ansible_vars} ${var.ansible_vars2} ${var.ansible_playbooks}"
  }
}
