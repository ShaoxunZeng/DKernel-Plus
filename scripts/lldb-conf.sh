#!/bin/bash

echo -e "file $3\n\
gdb-remote 1234\n\
settings set target.source-map $1 $2" > .lldbinit