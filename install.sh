#!/bin/sh -eux
# Install swarmsim on a new ubuntu machine. Tested on ec2 ubuntu 14.04.
# For ec2, first open port 9000 in the 3c2 firewall:
# - directions: http://stackoverflow.com/questions/17161345/how-to-open-a-web-server-port-on-ec2-instance
# - security group: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups:sort=groupId
#
# Usage:
#
#    sh | curl https://raw.githubusercontent.com/erosson/swarm/master/install.sh
#

# first, all the sudo stuff.
sudo apt-get update
# nodejs-legacy symlinks nodejs -> node, like node built from source in every other non-debian system
# ruby-dev needed to build compass
sudo apt-get install -y git nodejs nodejs-legacy npm ruby ruby-dev phantomjs
sudo npm install -g yo generator-angular
sudo gem install compass
# updates too.
sudo npm update yo generator-angular

# check out the package and install its deps.
test -d swarm || git clone https://github.com/erosson/swarm.git
cd swarm
npm install
bower install

# everything's installed! test it.
grunt
grunt build
grunt test
# `grunt serve` to run on port 9000.
