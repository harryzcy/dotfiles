#!/usr/bin/env zsh

if ! command -v git &> /dev/null
then
    echo "git could not be found"
    exit 1
fi

if ! command -v zsh &> /dev/null
then
    echo "zsh could not be found"
    exit 1
fi

ls -a $HOME/.oh-my-zsh

if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "oh-my-zsh could not be found"
    # exit 1
else
    ls -a $HOME/.oh-my-zsh
fi
