#! /bin/bash

tmux new-session -d -s daemon 'eudico delegated daemon --genesis=gen.gen' \; \
split-window 'eudico wait-api; eudico wallet import --as-default --format=json-lotus key.key; eudico delegated miner; sleep 2' \;

eudico wait-api

if [ -s /config/peerID.txt ]; then
        # Connect to node-0
        peerID=$(</config/peerID.txt)
        eudico net connect $peerID
else
        # Create peerID file
        eudico net listen | head -n 1 > /config/peerID.txt
fi

# Port Forward localhost bound port 1234
socat tcp-listen:8000,reuseaddr,fork tcp:localhost:1234 &

# Run forever until exit
while :
do
	sleep 1
done
