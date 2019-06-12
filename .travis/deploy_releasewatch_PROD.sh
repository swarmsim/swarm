#!/bin/sh -eux
cd "`dirname "$0"`"
sh -eux deploy_releasewatch.sh git@github.com:swarmsim-coffee/swarmsim-coffee.github.io.git 1 "$@"
sh -eux deploy_releasewatch.sh git@github.com:swarmsim/swarmsim.github.io.git 1 "$@"
sh -eux deploy_releasewatch.sh git@github.com:swarmsim-dotcom/swarmsim-dotcom.github.io.git 1 "$@"
