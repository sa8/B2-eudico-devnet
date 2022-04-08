kubectl delete -f ./deploy/
kubectl delete -f ./deploy/bitcoin
k3d cluster delete eudico
make start
make show_config