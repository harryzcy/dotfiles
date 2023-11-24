#!/usr/bin/env bash

if [[ -z "$IS_DEV_MACHINE" ]]; then
  IS_DEV_MACHINE=false

  os=$(detect_os)
  if [[ "$os" == 'macos' ]]; then
    IS_DEV_MACHINE=true
  elif [[ "$os" == 'linux' ]]; then
    if [[ "$(hostname -s)" = gpu-* ]]; then
      IS_DEV_MACHINE=true
    fi
  fi
fi
