#!/bin/sh -eux
cd "`dirname "$0"`/.."
package_version=`echo 'console.log(require("./package.json").version)' | node`
repo_version=`echo 'console.log(require("./.travis/tmp/repo/version.json").version)' | node`
echo $package_version $repo_version
[ "${package_version}" != "${repo_version}" ]
