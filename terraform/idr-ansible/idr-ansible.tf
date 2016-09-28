variable "wait_for" {
  description = "Wait for this variable to be populated"
  default = ""
}

variable "ansible_vars" {
  description = "Ansible playbook command line variables"
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

# Run ansible once all containers are running
resource "null_resource" "ansible" {
  triggers {
    wait_for = "${var.wait_for}"
  }
  provisioner "local-exec" {
    command = "cd ${var.ansible_workdir} && ansible-playbook -i ${var.ansible_inventory} ${var.ansible_vars} ${var.ansible_playbooks}"
  }
}
