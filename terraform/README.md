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

To destroy:

    terraform destroy
