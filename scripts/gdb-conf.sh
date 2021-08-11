#!/bin/bash

echo -e "file ./kernel/kernel-5.13.sym\n\
target remote :1234\n\
directory $1" > .gdbinit