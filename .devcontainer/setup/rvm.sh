#!/bin/bash
set -eux

# installing compass is a huge pain, but replacing it is a huger pain.
RUBY_VERSION=ruby-2.5
rvm install $RUBY_VERSION

# rvm use --default ruby-2.5   # NOPE, not in shell scripts
# https://rvm.io/rvm/basics
# https://stackoverflow.com/questions/10632066/cant-change-rvm-default
source $(rvm $RUBY_VERSION do rvm env --path)
rvm alias delete default
rvm alias create default $RUBY_VERSION

gem install compass

ruby --version
compass --version