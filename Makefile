# makefile for wireguard-config-generator

REQUIRED_VARS = WG_NAME WG_PORT WG_SERVER WG_COUNT WG_NETNUM WG_PEERING

default: config

# break with helpful message if a requred variable isn't set
environment: 
	$(foreach var,${REQUIRED_VARS},$(if ${${var}},,$(error ${var} is empty)))

config: environment
	./scripts/wireguard_config_generator
