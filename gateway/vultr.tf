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

# export TF_VAR_ADMIN_IP=any	# source IP of admin system ssh connections
# export TF_VAR_PLAN_ID=201	# 1024 MB RAM,25 GB SSD,1.00 TB BW
# export TF_VAR_REGION_ID=3	# Dallas
# export TF_VAR_OS_ID=412	# OpenBSD 6.8 x64
# export TF_VAR_HOSTNAME=server
# export TF_VAR_NETWORK=100  # 3rd octet of VPN network number
# export TF_VAR_PORT=51820   # UDP port for wireguard packets

variable ADMIN_IP {
  type = string
  default = "any"
}

variable NETWORK {
  type = string
  default = "100"
}

variable PORT {
  type = string
  default = "51820"
}

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

resource "vultr_ssh_key" "vpn_sshkey" {
  name = "${var.HOSTNAME}_sshkey"
  ssh_key = file("config/${var.HOSTNAME}-key.pub")
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
  provisioner "local-exec" {
    command = "scripts/wireguard_config_generator ${self.main_ip}"
  }
  provisioner "local-exec" {
    command = "echo ${self.main_ip} >config/endpoint"
  }
  provisioner "file" {
    source = "scripts/config.sh"
    destination = "/root/config.sh"
    connection {
      type = "ssh"
      user = "root"
      host = self.main_ip
      private_key = file("config/${var.HOSTNAME}-key")
    }
  }
  provisioner "file" {
    source = "gateway.conf"
    destination = "/etc/hostname.wg0"
    connection {
      type = "ssh"
      user = "root"
      host = self.main_ip
      private_key = file("config/${var.HOSTNAME}-key")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sh /etc/netstart wg0",
      "ifconfig wg0",
      "chmod +x /root/config.sh",
      "echo Before config.sh",
      "echo /root/config.sh ${var.ADMIN_IP} ${var.NETWORK} ${var.PORT}",
      "/root/config.sh ${var.ADMIN_IP} ${var.NETWORK} ${var.PORT} >/root/config.log 2>&1",
      "echo After config.sh",
    ]
    connection {
      type = "ssh"
      user = "root"
      host = self.main_ip
      private_key = file("config/${var.HOSTNAME}-key")
    }
  }
}

output "IP" {
  value = vultr_server.vpn_server.main_ip
}
