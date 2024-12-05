#!/usr/bin/env bash

if [[ -f ~/.profile ]]; then
  source ~/.profile
fi

. "$HOME/.cargo/env"
