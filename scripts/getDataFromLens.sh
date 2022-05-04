#!/bin/bash
for i in {0..21}
do
	kubectl cp default/eudico-node-$i:data.txt data/5-test-$i.txt
done
