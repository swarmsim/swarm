#!/bin/sh -eux
echo $NGROK_SWARMSIM > /dev/null #fail undefined check early
grunt="serve"
if [ $# -ge 1 ]; then
  grunt="$1";shift
fi
parallel -j 2 --tag --linebuffer <<EOF
grunt $grunt
ngrok -log stdout start swarmdev.ngrok.com > /dev/null
EOF

# ~/.ngrok has our auth token and password in it so we can't commit it, but it
# looks something like this: 
# (auth token from ngrok.com)
# 
# auth_token: fgsfds
# tunnels:
#   swarmdev.ngrok.com:
#     auth: "user:password"
#     remote_port: 55728
#     proto:
#       http: 9000
#       # no https, sadly - livereload gets upset
#       # this means we should be careful about connecting over wifi
#       #https: 9000
#       tcp: 55728
