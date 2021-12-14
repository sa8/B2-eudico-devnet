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
fi

eudico delegated daemon --genesis=gen.gen &
eudico wait-api

if [ -s /config/peerID.txt ]; then
        # Connect to node-0
        peerID=$(</config/peerID.txt)
        eudico net connect $peerID
else
        eudico wallet import --as-default --format=json-lotus key.key
        eudico delegated miner &

        # Create peerID file
        eudico net listen | head -n 1 > /config/peerID.txt
fi

# Port Forward localhost bound port 1234
#socat tcp-listen:8000,reuseaddr,fork tcp:localhost:1234 &

# Run forever until exit
while :
do
	sleep 1
done
