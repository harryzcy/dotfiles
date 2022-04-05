#!/bin/zsh

if ! command -v zsh &> /dev/null
then
    echo "zsh could not be found"
    exit 1
fi

# temp fix
echo ${ZSH}
if [[ -z ${ZSH} || ! -d ${ZSH} ]]; then
    echo "oh-my-zsh could not be found"
    # exit 1
fi

if ! command -v git &> /dev/null
then
    echo "git could not be found"
    exit 1
fi
