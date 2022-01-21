FROM ubuntu

RUN apt update && apt install -y curl jq

COPY miner.sh ./miner.sh
RUN chmod +x ./miner.sh

CMD ["./miner.sh"]