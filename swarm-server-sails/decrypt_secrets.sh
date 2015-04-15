#!/bin/sh -eux
# Ask @erosson for .secrets_key (but you probably won't get it).
openssl aes-256-cbc -k .secrets_key -in secrets.tar.enc -d | tar -xv
