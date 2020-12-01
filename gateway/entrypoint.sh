#!/bin/bash

set -e

COMMAND=$1
COMMAND=${COMMAND:-deploy}

# configuration constants
AUTO_APPROVE=-auto-approve
CFG_DIR=/root/config
#export TF_LOG=DEBUG

# environment defaults
WG_GATEWAY=${WG_GATEWAY:-gateway}
WG_NETWORK=${WG_NETWORK:-100}
WG_PORT=${WG_PORT:=50820}
WG_NAME=${WG_NAME:-gateway}
WG_VPS=${WG_VPS:=vultr}

# export env vars for terraform
export TF_VAR_HOSTNAME=${WG_NAME}
export TF_VAR_NETWORK=${WG_NETWORK}
export TF_VAR_PORT=${WG_PORT}
export TF_VAR_ADMIN_IP="$(curl -s ipinfo.io/ip)"

# record environment 
set | egrep ^WG_ >/root/config/env
set | egrep ^TF_ >>/root/config/env

# ssh_key
SSH_KEY=${CFG_DIR}/${WG_NAME}-key

# if the specified ssh key doesn't exist, create it
[ -e ${SSH_KEY} ] || ssh-keygen -t ed25519 -f ${SSH_KEY} -N ""

case "$COMMAND" in 
  deploy)
    terraform apply ${AUTO_APPROVE}
    for CFG in $(ls peer*.conf | awk -F. '{print $1}'); do
      qrencode -t PNG -r $CFG.conf -o $CFG.png;
      qrencode -t ANSIUTF8 -r $CFG.conf -o $CFG-qr.txt;
    done
    cp peer*.* ${CFG_DIR}
  ;;
  destroy) terraform destroy ${AUTO_APPROVE};;
  shell) ssh -i ${SSH_KEY} root@$(cat config/endpoint);;
  *) exec $@;;
esac
