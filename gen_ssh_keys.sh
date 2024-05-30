#!/bin/bash

mkdir -p ssh
ssh-keygen -b 2048 -t rsa -f ssh/id_rsa -q -N ""
cp ssh/id_rsa.pub ssh/authorized_keys

cp -r ssh ssh_local

sudo chown -R 1000:1000 ssh
