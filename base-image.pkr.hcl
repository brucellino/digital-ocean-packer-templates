packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
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
  default     = "packer-base-droplet"
  description = "The name of the droplet used during provisioning"
}

variable "snapshot_name" {
  type        = string
  default     = "base-image"
  description = "The name of the snapshot that will be assigned"
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

// variable "space_name" {
//   type = string
//   default = "hah-images"
//   description = "Name of the DO space that images are stored in" 
// }

source "digitalocean" "base-image" {
  snapshot_name      = var.snapshot_name
  api_token          = vault("digitalocean/data/tokens", "packer")
  image              = "ubuntu-21-10-x64"
  region             = var.region
  size               = var.size
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
    playbook_file    = "base-image.yml"
    ansible_env_vars = []
  }

  // post-processor "digitalocean-import" {
  //   api_token         = vault("digitalocean/data/tokens", "packer")
  //   spaces_key        = vault("digitalocean/data/tokens", "spaces_key")
  //   spaces_secret     = vault("digitalocean/data/tokens", "spaces_secret")
  //   image_name        = var.snapshot_name
  //   space_name        = var.space_name
  //   spaces_region     = var.region
  //   image_description = "Base image for Packer"
  //   image_regions     = ["ams3"]
  //   image_tags        = ["packer", "base-image"]
  // }
}