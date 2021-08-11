#!/bin/bash

# arg $1: disk img name
# arg $2: disk img size
 docker run -it --privileged -v $(pwd):/root -w /root ubuntu ./scripts/docker-build-disk-inner.sh $1 $2