#!/bin/sh -eux
./.travis/deploy_releasewatch_PROD.sh 1 || exit 1
grunt test && grunt deploy-prod
