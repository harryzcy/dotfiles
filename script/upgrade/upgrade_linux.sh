#!/usr/bin/env zsh

if [[ $(hostname -s) = gpu-* ]]; then
  kubectl krew update
  kubectl krew upgrade
fi
