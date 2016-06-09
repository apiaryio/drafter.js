#!/usr/bin/env bash

set -e

RUNEMRUN=off
DEBUG=off
UGLIFY=off
while [ $# -gt 0 ]
do
    case "$1" in
        -e)  RUNEMRUN=on;;
        -d)  DEBUG=on;;
        -u)  UGLIFY=on;;
        -*)
            echo >&2 "usage: $0 [-e] [-d] [-u]"
            exit 1;;
        *)  break;;
    esac
    shift
done

PYVER=`python -V 2>&1 | cut -d" " -f2 | cut -d. -f1`

if test $PYVER -eq 3; then
    PY=python2;
else
    PY="";
fi

FLAGS=""

if test "x$RUNEMRUN" = "xon"; then
    FLAGS="$FLAGS --emrun";
fi

if test "x$DEBUG" = "xon"; then
    FLAGS="$FLAGS -O0 -g";
    BUILDFLAGS=""
    UGLIFY=off
else
    FLAGS="$FLAGS -Oz --llvm-lto 1";
    BUILDFLAGS="-Oz"
fi

DRAFTER_PATH="ext/drafter"

(
  cd "$DRAFTER_PATH"
  emconfigure $PY ./configure --shared
  emmake make libdrafter CXXFLAGS=$BUILDFLAGS
)

mkdir -p lib

em++ $FLAGS "$DRAFTER_PATH/build/out/Release/lib.target/libdrafter.so" \
  -s EXPORTED_FUNCTIONS="['_drafter_c_parse']" \
  -s DISABLE_EXCEPTION_CATCHING=0 \
  -o lib/drafter.js  \
  --pre-js src/pre.js \
  --post-js src/post.js

em++ $FLAGS --memory-init-file 0 "$DRAFTER_PATH/build/out/Release/lib.target/libdrafter.so" \
  -s EXPORTED_FUNCTIONS="['_drafter_c_parse']" \
  -s DISABLE_EXCEPTION_CATCHING=0 \
  -o lib/drafter.nomem.js \
  --pre-js src/pre.js \
  --post-js src/post.js

if test "x$UGLIFY" = "xon"; then
    uglifyjs lib/drafter.js -o drafter.js -c;
    mv drafter.js lib/drafter.js;
fi
