# Bitcoin regtes miner


Dockerfiles used to build the bitcoin regtest miner image for this specific deployment.

Only use in this repo!

```
$ docker build -t rllola/regtest-miner .
```

## Notes

The prefund transaction is only working for this `gen.gen` file and distributed keys that you can found under `data` in https://github.com/Zondax/eudico/tree/zondax/eudico/data

Modifying only one will required updating the address.