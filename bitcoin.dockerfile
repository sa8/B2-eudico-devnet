FROM kylemanna/bitcoind:latest

RUN mkdir -p /bitcoin/.bitcoin
COPY ./bitcoin.conf /bitcoin/.bitcoin

EXPOSE 8333 8332 18333 18332 38333 38332 18444 18443