#!/bin/sh -eux
env -i `cat secrets/local/env.sh` node_modules/forever/bin/forever -w app.js
