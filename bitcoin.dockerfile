FROM kylemanna/bitcoind:latest

RUN mkdir -p /bitcoin/.bitcoin
COPY ./bitcoin.conf /bitcoin/.bitcoin