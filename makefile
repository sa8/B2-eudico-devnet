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

DOCKER_EUDICO_IMAGE=zondax/filecoin-eudico:latest
DOCKERFILE_EUDICO=./eudico.dockerfile

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

rebuild_eudico:
	docker image build --no-cache  -t $(DOCKER_EUDICO_IMAGE) -f $(DOCKERFILE_EUDICO) .
.PHONY: rebuild_eudico

clean:
	docker rmi $(DOCKER_EUDICO_IMAGE)
.PHONY: clean

stop:
	bash -c /usr/local/bin/k3s-killall.sh
	killall k3s-server
.PHONY: stop

start:
	nohup bash -c "k3s server --docker &"
.PHONY: start

run_deployment:
	k3s kubectl apply -f ./deploy
.PHONY: run_deployment

run_monitoring:
	k3s kubectl create namespace monitoring ;\
	k3s kubectl apply -f ./deploy/monitoring
.PHONY: run_monitoring

run_all: run_monitoring run_deployment
.PHONY: run_all

delete_monitoring:
	k3s kubectl delete -f ./deploy/monitoring
.PHONY: delete_monitoring

delete_deployment:
	k3s kubectl delete -f ./deploy/deployment.yaml
	k3s kubectl delete -f ./deploy/volume.yaml
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
	k3s kubectl exec --stdin --tty $(NODE_NAME)$(NODEID) -- /bin/bash
.PHONY: login

show_config:
	cat /etc/rancher/k3s/k3s.yaml
.PHONY: show_config

install_deps:
	curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_ENABLE=true sh -s
	k3s --version
.PHONY: install_deps

uninstall_deps:
	bash -c /usr/local/bin/k3s-uninstall.sh
.PHONY: uninstall_deps
	
