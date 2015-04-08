#!/bin/sh -eux
cd "`dirname "$0"`/.."
rm -rf .travis/tmp
git clone --depth 1 git@github.com:swarmsim-preprod/swarmsim-preprod.github.io.git .travis/tmp/preprod

cd .travis/tmp/preprod
mv -n index.html old.index.html
rm -f index.html
sed "s/<%= date %>/`date`/" ../../building.html > index.html
git add .
git config user.name "Evan Rosson (via travis-ci.org robots)"
git config user.email `echo "genivf-pv@fjnezfvz.pbz" | tr "[A-Za-z]" "[N-ZA-Mn-za-m]"`
git commit -m 'preprod build started'
git push
cd -

rm -rf .travis/tmp
