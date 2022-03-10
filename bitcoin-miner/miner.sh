#! /bin/bash

sleep 30

curl -u sarah:pikachutestnetB2 -X POST \
    btc-rpc:18332 \
    -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"createwallet\", \"params\": [\"wow\"]}" \
    -H 'Content-Type:application/json'

ADDRESS=$(curl -u sarah:pikachutestnetB2 -X POST \
    btc-rpc:18332 \
    -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"getnewaddress\", \"params\": [\"wow\"]}" \
    -H 'Content-Type:application/json' | jq -r '.result')

echo "$ADDRESS"

curl -u sarah:pikachutestnetB2 -X POST \
    btc-rpc:18332 \
    -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"generatetoaddress\", \"params\": [150, \"$ADDRESS\"]}" \
    -H 'Content-Type:application/json'

curl -u sarah:pikachutestnetB2 -X POST \
    btc-rpc:18332 \
    -d "{\"jsonrpc\": \"1.0\", \"id\":\"wow\", \"method\": \"sendtoaddress\", \"params\": [\"bcrt1p4ffl08gtqmc00j3cdc8x9tnqy8u4c0lr8vryny8um605qd78w7vs90n7mx\", 50]}" \
    -H 'Content-Type:application/json'

while sleep 1; do curl -u sarah:pikachutestnetB2 -X POST \
    btc-rpc:18332 \
    -d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"generatetoaddress\", \"params\": [1, \"$ADDRESS\"]}" \
    -H 'Content-Type:application/json'; done