#!/bin/sh -eux
cd "`dirname "$0"`/.."
rm -rf .travis/tmp
remote='git@github.com:swarmsim-preprod/swarmsim-preprod.github.io.git'
git clone --depth 1 $remote .travis/tmp/repo

cd .travis/tmp/repo
releasedir=releasewatch
rm -rf $releasedir
cp -rp ../../$releasedir $releasedir
sed -i "s/<%= date %>/`date`/" $releasedir/index.html
git add .
git config user.name "Evan Rosson (via travis-ci.org robots)"
git config user.email `echo "genivf-pv@fjnezfvz.pbz" | tr "[A-Za-z]" "[N-ZA-Mn-za-m]"`
git commit -m "build started. visit /$releasedir/ in a browser to watch for completion."
git push
cd -

rm -rf .travis/tmp
