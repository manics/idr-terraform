IDR Terraform
=============

1. Symlink one of the `tf` files in `deployments/` into this directory, e.g.

    ln -s deployments/docker.tf

2. Initialise modules (this is required even if the module is in this directory):

    terraform get

3. Check what terraform would do (doesn't change anything)

    terraform plan -var docker_privileged=True

4. Run the deployment

    terraform apply -var docker_privileged=True

   This creates a file `terraform.tfstate` in the current directory, which is required for other Terraform commands.
   Without this file Terraform will recreate everything instead of modifying or removing the existing resources.

To show the current state:

    terraform show

To destroy:

    terraform destroy

Taint the ansible resource to force it to be re-run:

    terraform taint -module idr-ansible null_resource.ansible
