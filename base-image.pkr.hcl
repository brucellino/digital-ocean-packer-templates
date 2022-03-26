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
  default     = "base-droplet"
  description = "The name of the droplet"
}

variable "vpc_id" {
  type = string
  default = "06b0e26c-6fdf-48e5-b5fc-cf2c631b08df"
  description = "ID of the Digital Ocean VPC to use"
}

variable "tags" {
  type = list(string)
  default = [
    "packer",
    "base-image",
  ]
}

source "digitalocean" "base-image" {
  snapshot_name = var.droplet_name
  api_token          = vault("digitalocean/data/tokens", "packer")
  image              = "ubuntu-21-10-x64"
  region             = var.region
  size               = var.size
  ssh_username       = "root"
  private_networking = true
  droplet_name       = var.droplet_name
  monitoring = false
  vpc_uuid = var.vpc_id
  tags = var.tags
}

build {
  sources = ["source.digitalocean.base-image"]
}