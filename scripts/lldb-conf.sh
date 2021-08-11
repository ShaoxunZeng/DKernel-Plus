#!/bin/bash

echo -e "file ./kernel/kernel-5.13.sym\n\
gdb-remote 1234\n\
settings set target.source-map $1 $2" > .lldbinit