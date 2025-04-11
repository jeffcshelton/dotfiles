HOST=$(shell hostname)

config.jsonc: config.$(HOST).json config.common.json
	python merge.py $^ -o $@
