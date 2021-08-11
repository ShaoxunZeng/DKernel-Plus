#!/bin/bash

apt update && 
apt install wget &&
# arg $1: ubuntu img download link
wget $1