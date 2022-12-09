#!/bin/sh

for f in `ls *.html`; do
    NAME=`basename $f .html`
    echo "export {default as $NAME} from './$f'"
done