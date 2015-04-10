#!/bin/sh -eu
cat $@ | grep -hi version | cut -d ':' -f 2 | sed 's/^\s*"//' | sed 's/"[\s,]*$//'
