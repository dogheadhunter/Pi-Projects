PY_EX=examples/python-led
NODE_EX=examples/node-blink

.PHONY: help setup-python run-python run-node

help:
	@echo "Targets: setup-python run-python run-node deploy-python deploy-node"

setup-python:
	python -m venv venv
	venv/bin/pip install -r $(PY_EX)/requirements.txt

run-python:
	python3 $(PY_EX)/blink.py

run-node:
	cd $(NODE_EX) && npm install && node index.js

deploy-python:
	./scripts/deploy.sh $(PY_EX)

deploy-node:
	./scripts/deploy.sh $(NODE_EX)