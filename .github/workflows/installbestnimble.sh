#!/bin/bash

set -xe

OPTIONS="$(git ls-remote --tags https://github.com/nim-lang/nimble.git | cut -f2 | cut -d/ -f3 | grep -v '\^' | grep 'v' | cut -c2- | sort -V -r)"
for target_version in $OPTIONS; do
  if nimble install -y --verbose "nimble@${target_version}"; then
    echo "Installed ${target_version}"
    break
  else
    echo "failed"
  fi
done
nimble -v
