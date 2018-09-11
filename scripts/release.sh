#!/bin/bash

OS=`uname -s | tr '[:upper:]' '[:lower:]'`
TAG=`git describe --tags $CIRCLE_SHA1`

# Download GitHub releases script
curl -L -O https://github.com/aktau/github-release/releases/download/v0.6.2/$OS-amd64-github-release.tar.bz2
tar -xjf $OS-amd64-github-release.tar.bz2
GITHUB_RELEASE=./bin/$OS/amd64/github-release

# Create GitHub release
$GITHUB_RELEASE release -u apiaryio -r drafter.js --tag $TAG

$GITHUB_RELEASE upload -u apiaryio -r drafter.js --tag $TAG --name drafter.js --file lib/drafter.js
$GITHUB_RELEASE upload -u apiaryio -r drafter.js --tag $TAG --name drafter.js.mem --file lib/drafter.js.mem
$GITHUB_RELEASE upload -u apiaryio -r drafter.js --tag $TAG --name drafter-non-umd.wasm --file lib/drafter-non-umd.wasm
$GITHUB_RELEASE upload -u apiaryio -r drafter.js --tag $TAG --name drafter-non-umd.js --file lib/drafter-non-umd.js

# Use the CI host's NPM_TOKEN environment variable for auth
echo '//registry.npmjs.org/:_authToken=${NPM_TOKEN}' >.npmrc

# Unfortunately NPM doesn't respect .npmignore or use correct GPY files when
# calculating gypfile.
# Let's delete all the related files as a workaround.
# https://github.com/npm/read-package-json/pull/52
rm -fr **.gyp{,i}

# Publish to npm
npm publish
