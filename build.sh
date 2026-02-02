#! /bin/bash

clear
c3c test
c3c build

if [ ! -d "bythos.c3l/linked-libs/" ]; then
  mkdir bythos.c3l/linked-libs/
fi

if [ ! -d "bythos.c3l/linked-libs/linux-x64/" ]; then
  mkdir bythos.c3l/linked-libs/linux-x64/
fi

cp build/bythos.a bythos.c3l/linked-libs/linux-x64/libbythos.a

