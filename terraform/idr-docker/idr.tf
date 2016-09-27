# Variables
variable "idr_environment" {
  description = "IDR environment/deployment"
  default = "idr"
}

variable "docker_image_name" {
  description = "Docker image to use for all nodes"
  default = "manics/centos-systemd"
}

variable "privileged" {
  description = "Run Docker containers in privileged mode"
  default = false
}

variable "docker_ports_base" {
  description = "Use this as the base for exported port numbers (docker_ports_base+)"
  default = 10000
}

# Configure the Docker provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pull a Centos7 systemd image
# There's bug in Terraform which means sometime pulling images fails
#resource "docker_image" "c7systemd" {
#  name = "${var.docker_image_name}"
#  keep_locally = "true"
#}

# Create containers
resource "docker_container" "idr-database" {
  image = "${var.docker_image_name}"
  name = "${var.idr_environment}-database"
  labels = {
    groups = "${var.idr_environment}-database-hosts,database-hosts,${var.idr_environment}-hosts"
  }
  volumes = {
    host_path = "/sys/fs/cgroup"
    container_path = "/sys/fs/cgroup"
    read_only = true
  }
  privileged = "${var.privileged}"
}

resource "docker_container" "idr-omero" {
  image = "${var.docker_image_name}"
  name = "${var.idr_environment}-omero"
  labels = {
    groups = "${var.idr_environment}-omero-hosts,omero-hosts,${var.idr_environment}-hosts"
  }
  volumes = {
    host_path = "/sys/fs/cgroup"
    container_path = "/sys/fs/cgroup"
    read_only = true
  }
  privileged = "${var.privileged}"
}

resource "docker_container" "idr-gateway" {
  image = "${var.docker_image_name}"
  name = "${var.idr_environment}-gateway"
  labels = {
    groups = "${var.idr_environment}-proxy-hosts,proxy-hosts,${var.idr_environment}-hosts"
  }
  volumes = {
    host_path = "/sys/fs/cgroup"
    container_path = "/sys/fs/cgroup"
    read_only = true
  }
  ports = {
      internal = 80
      external = "${var.docker_ports_base + 80}"
  }
  ports = {
      internal = 443
      external = "${var.docker_ports_base + 443}"
  }
  privileged = "${var.privileged}"
}

output "database_ip" {
  value = "${docker_container.idr-database.ip_address}"
}

output "omero_ip" {
  value = "${docker_container.idr-omero.ip_address}"
}

output "gateway_ip" {
  value = "${docker_container.idr-gateway.ip_address}"
}
