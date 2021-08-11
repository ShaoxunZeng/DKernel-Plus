#!/bin/bash

# arg $1: ubuntu img download link
 docker run -it --privileged -v $(pwd):/root -w /root ubuntu ./scripts/docker-download-ubuntu-inner.sh $1 $2