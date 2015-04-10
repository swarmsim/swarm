#!/bin/sh -eux
./.travis/deploy_releasewatch_staging.sh 1 || exit 1
grunt test && grunt deploy-staging
