#!/bin/bash

if ! command -v zsh &> /dev/null
then
    echo "zsh could not be found"
    exit 1
fi
