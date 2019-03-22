#!/bin/bash

for script in *; do
    ln -s $script /usr/local/bin
done
