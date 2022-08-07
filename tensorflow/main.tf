terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.4.2"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.19.0"
    }
  }
}

# Admin parameters

variable "arch" {
  default = "amd64"
  description = "arch: What architecture is your Docker host on?"
  sensitive = true
}

variable "OS" {
  default = "Linux"
  description = <<-EOF
  What operating system is your Coder host on?
  EOF
  sensitive = true
}

variable "cpu" {
  description = "How many CPU cores for this workspace?"
  default     = "04"
  validation {
    condition     = contains(["04", "08", "16", "32"], var.cpu) # this will show a picker
    error_message = "Invalid CPU count!"
  }
}

variable "ram" {
  description = "How much RAM for your workspace? (min: 16 GB, max: 96 GB)"
  default     = "16"
  validation { # this will show a text input select
    condition     = contains(["16", "32", "64", "96"], var.ram) # this will show a picker
    error_message = "Ram size must be an integer between 16 and 96 (GB)."
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "coder" {
}

data "coder_workspace" "me" {
}

# jupyter
resource "coder_app" "jupyter" {
  agent_id      = coder_agent.dev.id
  name          = "Jupyter"
  icon          = "https://cdn.icon-icons.com/icons2/2667/PNG/512/jupyter_app_icon_161280.png"
  url           = "http://localhost:8888/@${data.coder_workspace.me.owner}/${data.coder_workspace.me.name}/apps/jupyter"
  relative_path = true
}

resource "coder_agent" "dev" {
  arch = var.arch
  os   = "linux"
  startup_script = <<EOT
#!/bin/bash
set -euo pipefail

# start jupyter
jupyter notebook --no-browser --port 8888 --NotebookApp.token='' --ip='*' --NotebookApp.base_url=/@${data.coder_workspace.me.owner}/${data.coder_workspace.me.name}/apps/jupyter
EOT
}

variable "docker_image" {
  description = "What Docker image would you like to use for your workspace?"
  default     = "latest"
  validation {
    condition   = contains(["latest", "2.9", "2.8"], var.docker_image)
  	error_message = "Invalid tag. This tag does not exist in the image registry."
  }
  # Prevents admin errors when the image is not found
  validation {
    condition     = fileexists("images/${var.docker_image}.Dockerfile")
    error_message = "Invalid Docker image. The file does not exist in the images directory."
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}-root"
}

resource "docker_image" "coder_image" {
  name = "coder-base-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  build {
    path       = "./images/"
    dockerfile = "${var.docker_image}.Dockerfile"
    tag        = ["coder-${var.docker_image}:v0.1"]
    build_arg = {
      USERNAME = "${data.coder_workspace.me.owner}"
    }
  }
  # Keep alive for other workspaces to use upon deletion
  keep_locally = false
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = docker_image.coder_image.latest
  cpu_shares = var.cpu
  memory = "${var.ram*1024}"
  runtime = "nvidia"
  gpus = "all"
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = lower(data.coder_workspace.me.name)
  dns      = ["1.1.1.1"]
  # Use the docker gateway if the access URL is 127.0.0.1
  command = ["sh", "-c", replace(coder_agent.dev.init_script, "127.0.0.1", "host.docker.internal")]
  env     = ["CODER_AGENT_TOKEN=${coder_agent.dev.token}"]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/${data.coder_workspace.me.owner}/"
    volume_name    = docker_volume.home_volume.name
    # host_path      = "/data/coder/"
    read_only      = false
  }
}
