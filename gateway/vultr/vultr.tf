terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "1.5.0"
    }
  }
}

provider "vultr" {
  # export VULTR_API_KEY=XXXXXXXXXXXXX
  rate_limit = 700
  retry_limit = 3
}

# export TF_VAR_PLAN_ID=201	# 1024 MB RAM,25 GB SSD,1.00 TB BW
# export TF_VAR_REGION_ID=3	# Dallas
# export TF_VAR_OS_ID=412	# OpenBSD 6.8 x64
# export TF_VAR_HOSTNAME=server

variable PLAN_ID {
  type=number
  default=201
}

variable REGION_ID {
  type=number
  default=3
}

variable OS_ID {
  type=number
  default=412
}

variable HOSTNAME {
  type=string
  default="gateway"
}

resource "vultr_startup_script" "vpn_script" {
  name = "${var.HOSTNAME}_config"
  script = file("../scripts/config.sh")
}

resource "vultr_ssh_key" "vpn_sshkey" {
  name = "${var.HOSTNAME}_sshkey"
  ssh_key = file("../config/${var.HOSTNAME}-key.pub")
}

resource "vultr_server" "vpn_server" {
  plan_id = var.PLAN_ID
  region_id = var.REGION_ID
  os_id = var.OS_ID
  hostname = var.HOSTNAME
  label = "${var.HOSTNAME}_instance"
  enable_ipv6 = false
  notify_activate = false
  ssh_key_ids = [vultr_ssh_key.vpn_sshkey.id]
  script_id = vultr_startup_script.vpn_script.id
}

output "IP" {
  value = vultr_server.vpn_server.main_ip
}
