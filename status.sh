#!/bin/sh
sudo bin/geth attach data_dir/geth.ipc --exec "istanbul.status();"