packer {
  required_plugins {
    digitalocean = {
      version = "= 1.0.3"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

variable "region" {
  type        = string
  default     = "ams3"
  description = "The region to deploy to"
}

variable "size" {
  type        = string
  default     = "s-1vcpu-1gb"
  description = "The size of the droplet"
}

variable "droplet_name" {
  type        = string
  default     = "consul-server-droplet"
  description = "The name of the droplet"
}

variable "vpc_id" {
  type        = string
  default     = "08a4d3ad-a229-40dd-8dd4-042bda3e09bc"
  description = "ID of the Digital Ocean VPC to use"
}

variable "tags" {
  type = list(string)
  default = [
    "packer",
    "base-image",
  ]
}

variable "roles_path" {
  description = "Path to Ansible roles"
  default = "roles"
  type = string
}

source "digitalocean" "base-image" {
  snapshot_name      = var.droplet_name
  api_token          = vault("digitalocean/data/tokens", "packer")
  image              = "ubuntu-21-10-x64"
  region             = var.region
  size               = var.size
  // ssh_key_id = "test-instances"
  ssh_username       = "root"
  private_networking = true
  droplet_name       = var.droplet_name
  monitoring         = false
  vpc_uuid           = var.vpc_id
  tags               = var.tags
}

build {
  sources = ["source.digitalocean.base-image"]
  provisioner "ansible" {
    groups = ["consul_servers"]
    playbook_file    = "consul-servers.yml"
    ansible_env_vars = [
      "ANSIBLE_ROLES_PATH=${var.roles_path}"
    ]
  }
}