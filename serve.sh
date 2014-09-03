#!/bin/sh -eux
echo $NGROK_SWARMSIM > /dev/null #fail undefined check early
grunt="serve"
if [ $# -ge 1 ]; then
  grunt="$1";shift
fi
parallel -j 2 --tag --linebuffer <<EOF
grunt $grunt
ngrok -log stdout -subdomain=$NGROK_SWARMSIM 9000 > /dev/null
EOF
