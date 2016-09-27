IDR Terraform
=============

Initialise modules (this is required even if the module is in this directory):

    terraform get

Create docker containers and run Ansible:

    terraform apply -var docker_privileged=True

Destroy:

    terraform destroy
