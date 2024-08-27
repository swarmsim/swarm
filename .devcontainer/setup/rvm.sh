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

# compass tries to install ffi 1.17.0 by default (as of 2024/08/27), but that fails because we're pinned to such old versions of everything.
# manually installing 1.16.0 seems to work.
gem install ffi -v 1.16.0  
gem install compass

ruby --version
compass --version