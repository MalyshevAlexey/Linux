#!/bin/bash

source ./bf/boot.sh
import scripts/another

[[ $1 != "" ]] && echo "da" || echo "net"
