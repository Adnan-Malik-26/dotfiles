#!/usr/bin/env bash

cliphist list | fzf | cliphist decode | wl-copy
