#!/bin/bash

source ./bfw/boot.sh
import scripts/another

[[ $1 != "" ]] && echo "da" || echo "net"
