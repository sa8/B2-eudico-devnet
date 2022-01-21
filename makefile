#*******************************************************************************
#*   (c) 2021 Zondax GmbH
#*
#*  Licensed under the Apache License, Version 2.0 (the "License");
#*  you may not use this file except in compliance with the License.
#*  You may obtain a copy of the License at
#*
#*      http://www.apache.org/licenses/LICENSE-2.0
#*
#*  Unless required by applicable law or agreed to in writing, software
#*  distributed under the License is distributed on an "AS IS" BASIS,
#*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*  See the License for the specific language governing permissions and
#*  limitations under the License.
#********************************************************************************

DOCKER_BITCOIN_IMAGE=zondax/bitcoin-node:latest
DOCKER_EUDICO_IMAGE=zondax/filecoin-eudico:latest
DOCKER_REGTEST_IMAGE=regtest-miner:latest
DOCKERFILE_EUDICO=./eudico.dockerfile
DOCKERFILE_BITCOIN=./bitcoin.dockerfile

CONTAINER_NAME=eudiconode
CONTAINER_DEVNET_NAME=filecoin-eudico-devnet

HOST_URL=http://localhost

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)
LOTUS_API_PORT = 1234
NPROC=16
SCALE=4
NODEID=0
NODE_NAME=eudico-node-

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	NPROC=$(shell nproc)
endif
ifeq ($(UNAME_S),Darwin)
	NPROC=$(shell sysctl -n hw.physicalcpu)
endif

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

all: run
.PHONY: all

build_eudico:
	docker image build -t $(DOCKER_EUDICO_IMAGE) -f $(DOCKERFILE_EUDICO) .
.PHONY: build_eudico

import_eudico:
	k3d image import $(DOCKER_EUDICO_IMAGE) -c eudico 
.PHONY: import_eudico

import_bitcoin:
	k3d image import $(DOCKER_BITCOIN_IMAGE) -c eudico 
.PHONY: import_bitcoin

build_regtest:
	cd ./bitcoin-miner
	docker image build -t $(DOCKER_REGTEST_IMAGE) .
.PHONY: build_regtest

import_regtest_miner:
	k3d image import $(DOCKER_REGTEST_IMAGE) -c eudico
.PHONY: import_regtest_miner

build_bitcoin:
	docker image build --no-cache -t $(DOCKER_BITCOIN_IMAGE) -f $(DOCKERFILE_BITCOIN) .
.PHONY: build_bitcoin

rebuild_eudico:
	docker image build --no-cache  -t $(DOCKER_EUDICO_IMAGE) -f $(DOCKERFILE_EUDICO) .
.PHONY: rebuild_eudico

clean:
	docker rmi $(DOCKER_EUDICO_IMAGE)
.PHONY: clean

stop:
	k3d node stop eudico
.PHONY: stop

start:
	k3d cluster create eudico  
.PHONY: start

delete:
	k3d node delete eudico
.PHONY: delete

run_eudico:
	kubectl apply -f ./deploy
.PHONY: run_eudico

run_bitcoin:
	kubectl apply -f ./deploy/bitcoin
.PHONY: run_bitcoin

run_minio:
	kubectl apply -f ./deploy/minio
.PHONY: run_minio

run_monitoring:
	kubectl create namespace monitoring ;\
	kubectl apply -f ./deploy/monitoring
.PHONY: run_monitoring

run_all: run_monitoring run_bitcoin run_minio run_eudico
.PHONY: run_all

delete_monitoring:
	kubectl delete -f ./deploy/monitoring
.PHONY: delete_monitoring

delete_deployment:
	kubectl delete -f ./deploy/deployment.yaml
	kubectl delete -f ./deploy/volume.yaml
.PHONY: delete_deployment

delete_all: delete_monitoring delete_deployment
.PHONY: delete_all

scale_deployment:
	k3s kubectl scale --replicas=$(SCALE) -f ./deploy/deployment.yaml
.PHONY: scale_deployment

expose_grafana:
	nohup bash -c "kubectl -n monitoring port-forward --address 0.0.0.0 service/grafana 3000:3000 &"
	@echo "\n\tGrafana available at ${HOST_URL}:3000\n"
.PHONY: expose_grafana

login:
	kubectl exec --stdin --tty $(NODE_NAME)$(NODEID) -- /bin/bash
.PHONY: login

show_config:
	k3d kubeconfig get eudico        
.PHONY: show_config

install_deps:
	wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
	k3d --version
.PHONY: install_deps
	
