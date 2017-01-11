#!/bin/sh -eux
cd "`dirname "$0"`/.."
rm -rf .travis/tmp
remote=$1;shift
checkversion=${1-''}
git clone --depth 1 $remote .travis/tmp/repo
if [ "$checkversion" != "" ]; then
  sh -eux ./.travis/checkversion.sh || exit 1
fi

cd .travis/tmp/repo
releasedir=releasewatch
rm -rf $releasedir
cp -rp ../../$releasedir $releasedir
sed -i "s/<%= date %>/`LC_ALL=en_US date`/" $releasedir/index.html
git add .
git config user.name "Evan Rosson (via travis-ci.org robots)"
git config user.email `echo "genivf-pv@fjnezfvz.pbz" | tr "[A-Za-z]" "[N-ZA-Mn-za-m]"`
git commit -m "build started. visit /$releasedir/ in a browser to watch for completion."
git push
cd -
