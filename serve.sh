#!/bin/sh -eux
grunt="serve"
if [ $# -ge 1 ]; then
  grunt="$1";shift
fi
parallel -j 2 --tag --linebuffer <<EOF
grunt $grunt
ngrok -log stdout -subdomain=swarm-demo 9000 > /dev/null
EOF
