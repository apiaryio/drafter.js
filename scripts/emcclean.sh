#!/usr/bin/env bash

cd ext/drafter && make clean
rm -rf generated
rm -rf ./lib/drafter.js ./lib/drafter.js.mem ./lib/drafter.nomem.js
