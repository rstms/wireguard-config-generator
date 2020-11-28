# makefile for wireguard-config-generator
#

NAME=gateway
DC=docker-compose --env-file ./env
MAKE=${DC} run ${NAME} make 

VPS=docker run -e VULTR_API_KEY vultr/vultr-cli


build:
	${DC} build

deploy: _deploy getconfig

_deploy:
	${MAKE} deploy

destroy:
	${MAKE} destroy 

shell:
	${MAKE} shell

bash:
	${DC} run ${NAME} bash -l

getconfig:
	${DC} run -T ${NAME} tar cO -C /root config | tar xv

setenv:
	@./configure.sh

getenv:
	@set | grep -e '^WG_\|^TF_'

clean:
	docker-compose stop
	docker system prune --all --volumes --force
	rm -f config/*


vpslist:
	for TYPE in ssh-key script instance; do ${VPS} $$TYPE list; done

vpsclean:
	${VPS} ssh-key list | awk '/${NAME}_sshkey/{print $$1}' | xargs -r -n 1 ${VPS} ssh-key delete
	${VPS} script list | awk '/${NAME}_config/{print $$1}' | xargs -r -n 1 ${VPS} script delete
	${VPS} instance list | awk '/${NAME}_instance/{print $$1}' | xargs -r -n 1 ${VPS} instance delete
