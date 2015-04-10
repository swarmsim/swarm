#!/bin/sh -eux
cd "`dirname "$0"`"
sh -eux deploy_releasewatch.sh git@github.com:swarmsim-staging/swarmsim-staging.github.io.git "$@"
