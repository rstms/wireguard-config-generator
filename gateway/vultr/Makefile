# terraform makefile
#
TERRAFORM:=terraform
SCRIPT_DIR=../scripts
CFG_DIR=../config
CONFIGURE:=${SCRIPT_DIR}/wireguard_config_generator
GATEWAY_IP=$(shell terraform output IP)
SSH_KEY=${CFG_DIR}/${TF_VAR_HOSTNAME}-key
SSH=ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no root@${GATEWAY_IP}
STATE=terraform.tfstate
SAVE_STATE=[ -e ${STATE} ] && cp ${STATE} ${CFG_DIR}/${STATE} || true
LOAD_STATE=@set -e;[ -e ${CFG_DIR}/${STATE} ] && cp ${CFG_DIR}/${STATE} . || (echo Missing required state: ${CFG_DIR}/${STATE}; exit 1)

deploy: ${SSH_KEY} apply config 

${SSH_KEY}:
	@echo Generating new SSH key...
	ssh-keygen -t ed25519 -f $@ -N ""

config:
	@${LOAD_STATE}
	${SCRIPT_DIR}/ssh_wait ${GATEWAY_IP} ${SSH_KEY}
	@echo Generating VPN configuration...
	${CONFIGURE} ${GATEWAY_IP}
	cp peer*.conf ${CFG_DIR}
	cat gateway.conf | ${SSH} "cat ->/etc/hostname.wg0"
	${SSH} chmod 640 /etc/hostname.wg0
	${SSH} sh /etc/netstart wg0
	${SSH} ifconfig wg0

apply: ${SSH_KEY}
	@echo Generating VPS resources...
	${TERRAFORM} apply
	${SAVE_STATE}

plan: ${SSH_KEY}
	${TERRAFORM} plan
	${SAVE_STATE}

destroy:
	@echo Deleting VPS resources...
	${LOAD_STATE}
	${TERRAFORM} destroy
	${SAVE_STATE}

test: plan

clean: destroy

shell:
	${LOAD_STATE}
	${TERRAFORM} refresh
	${SSH}
	${SAVE_STATE}
