#!/bin/sh -e

docker run --rm hesusruiz/alagethng:latest cat /geth >bin/geth
chmod +x bin/geth
docker run --rm hesusruiz/alagethng:latest cat /newnodekey >bin/newnodekey
chmod +x bin/newnodekey

echo "Updated geth"
bin/geth version
