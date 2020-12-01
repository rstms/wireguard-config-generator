#
# makefile for wireguard-config-generator
#

NAME=gateway
DC=docker-compose --env-file ./env
RUN=${DC} run ${NAME}

# use local vultr-cli
CLI=vultr-cli

# uncomment to use docker version of vultr-cli
#VPS=docker run -e VULTR_API_KEY vultr/vultr-cli

default: build deploy

build:
	${DC} build --build-arg VPS=vultr --no-rm

deploy:
	${RUN} deploy 

destroy:
	${RUN} destroy 

shell:
	${RUN} shell

bash:
	${RUN} bash -l

tarconfig:
	@${DC} run -T ${NAME} tar czO -C /root config >config.tgz

setenv:
	@./configure

getenv:
	@(set | grep -e '^WG_\|^TF_') || true

sterile: clean
	docker-compose stop
	docker system prune --all --volumes --force
	rm -f config/*

vpslist:
	for TYPE in ssh-key script instance; do ${CLI} $$TYPE list; done

clean:
	${CLI} ssh-key list | awk '/${NAME}_sshkey/{print $$1}' | xargs -r -n 1 ${CLI} ssh-key delete
	${CLI} script list | awk '/${NAME}_config/{print $$1}' | xargs -r -n 1 ${CLI} script delete
	${CLI} instance list | awk '/${NAME}_instance/{print $$1}' | xargs -r -n 1 ${CLI} instance delete
