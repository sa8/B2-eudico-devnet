# filecoin-eudico-devnet
Eudico devnet deployment based on k3d.
The deployment consist of:
 - eudico nodes (scalable)
 - bitcoin regtest node + miner
 - minio
 - grafana


## Quick start

  

### Install k3d

  Install k3d:
```
make install_deps
```

 Install kubectl
```
sudo apt-get install kubectl
```


### Start k3d node
```
make start
```
  

### Build Eudico node image
```
make build_eudico
make import_eudico
  ```

### Build Bitcoin node image
```
make build_bitcoin
make import_bitcoin
  ```

### Deploy

The following command will deploy all services and instances into the k3d cluster
```
make run_all
```

### Scaling up nodes

By default, three eudico nodes will be started. You can easily scale up the numbers of nodes by doing:
```
make scale_deployment SCALE=5  # two more eudico nodes will be spinned
```
  

### Connecting to cluster

k3d doesn't come with a dashboard of its own. It's recommended to use tools like [lens](https://k8slens.dev/) for accessing cluster from the gui or vs-code [extension](https://code.visualstudio.com/docs/azure/kubernetes). Kubectl in other cases would work well on the remote machine. The following command will show the config for the k3s cluster which can be added to access the cluster remotely.
```
make show_config
```

In the config update the server field which says `https://127.0.0.1:[port]` to `https://[remote-machine-ip]:[port]` before using it.


### Monitoring Services

Using prometheus and grafana for monitoring. The following makefile target will use the configs from `/deploy/monitoring`
```
make run_monitoring
```
The grafana dashboard is running inside the cluster and needs to be exposed in order to access it locally or remotely. To expose grafana is the following command:
```
make expose_grafana
```
or using command in case port 3000 is already in use, replace [port] below
```
kubectl -n monitoring port-forward --address 0.0.0.0 service/grafana [port]:3000
```
  

### Logging in into a node

Nodes are named with incremental ID’s starting from 0: **eudico-node-0, eudico-node-1, ... , eudico-node-N**

For example, for logging in into node **eudico-node-1** just type:
```
sudo make login NODEID=1

tmux a  # Restores tmux session 
```
  
 ---

### Stopping k3s

Can be done using the makefile target or using the commands using the script and killing k3s-server
```
bash -c /usr/local/bin/k3s-killall.sh

sudo killall k3s-server
```
Makefile Target
```
sudo make stop
```
  

### Uninstalling k3s
```
make uninstall_deps
```
