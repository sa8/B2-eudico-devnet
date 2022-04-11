#! /bin/bash


# Copy eudico config files
# eudico-node-0 --> alice
# eudico-node-1 --> bob
# eudico-node-2 --> charlie
# eudico-node-N --> default (N > 2)

mkdir -p /root/.eudico/
if [ "$HOSTNAME" == "eudico-node-0" ]; then
    echo "Using Alice data"
    cp -r /eudico_data/alice/* /root/.eudico/
elif [ "$HOSTNAME" == "eudico-node-1" ]; then
         echo "Using Bob data"
         cp -r /eudico_data/bob/* /root/.eudico/
elif [ "$HOSTNAME" == "eudico-node-2" ]; then
         echo "Using Charlie data"
         cp -r /eudico_data/charlie/* /root/.eudico/
else
	echo "Using other config"
	cp /eudico_data/dom/config.toml /root/.eudico/
fi

# chmod because eudico complains
chmod 600 /root/.eudico/keystore/*

MUL=$(echo $HOSTNAME | sed 's/[^0-9]//g')

eudico delegated daemon --genesis=gen.gen &
eudico wait-api --timeout 90s

# Append own listening address to file
eudico net listen | head -n 1 >> /config/peerID.txt

# Connect to other nodes
sleep $((10*MUL))
while IFS= read -r peerID; do
	echo $peerID
	eudico net connect $peerID
done < /config/peerID.txt

# Start mining if node 0
if [ "$HOSTNAME" == "eudico-node-0" ]; then
	eudico wallet import --as-default --format=json-lotus key.key
	sleep 30
	eudico delegated miner &
fi

# Port Forward localhost bound port 1234
#socat tcp-listen:8000,reuseaddr,fork tcp:localhost:1234 &

# Run forever until exit
while :
do
	sleep 1
done
