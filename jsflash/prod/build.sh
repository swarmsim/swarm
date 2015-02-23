#!/bin/sh -eux
cd "`dirname "$0"`"
alias mxmlc=../flex/bin/mxmlc
mxmlc Storage.as -output ../../dist/storage.swf
