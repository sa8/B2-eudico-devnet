#!/bin/bash
for i in {1..5}
do
	kubectl cp default/eudico-node-$i:data.txt data/test-$i.txt
done
