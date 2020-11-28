#!/bin/bash
set -e
cd ${WG_VPS:-vultr}
export TF_VAR_HOSTNAME=${WG_NAME}
set | egrep ^WG_ >/root/config/env
set | egrep ^TF_ >>/root/config/env
case $1 in 
    build) make ;;
    destroy) make destroy;;
    shell) make shell;;
    *) exec $@;;
esac
