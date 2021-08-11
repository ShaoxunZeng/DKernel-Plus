#!/bin/bash

apt update && 
apt install qemu-utils &&
# arg $1: disk img name
# arg $2: disk img size
qemu-img create -f raw $1.raw $2 &&
mkfs -t ext4 ./$1.raw