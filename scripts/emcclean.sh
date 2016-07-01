#!/usr/bin/env bash

rm -rf generated
rm -rf ./build
rm -rf ./lib
rm -rf drafterjs.gyp
rm -rf config.gypi
cd ext/drafter && make distclean

