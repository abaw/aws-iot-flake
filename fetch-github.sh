#!/bin/sh
[ $# -eq 3 ] || { echo "Usage: $0 <owner> <repo> <rev>"; exit 1; }
nix shell github:seppeljordan/nix-prefetch-github -c nix-prefetch-github --fetch-submodules --rev "$3" "$1" "$2"
