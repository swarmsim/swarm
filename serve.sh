#!/bin/sh -eux
parallel -j 2 --tag --linebuffer <<EOF
grunt serve
ngrok -log stdout -subdomain=swarm-demo 9000 > /dev/null
EOF
