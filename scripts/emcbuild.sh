#!/usr/bin/env bash


function usage
{
    echo >&2 "usage: $0 [-e] [-d] [-u] [-x] [-j <num>]"
    echo >&2 "-e: build for use with emrun"
    echo >&2 "-d: debug build -O0 -g"
    echo >&2 "-x: extreme debug build -O0 -g4"
    echo >&2 "-j: same as make -j<x>"
}

set -e

RUNEMRUN=off
DEBUG=off
JX="-j"
while [ "$1" != "" ];
do
    case "$1" in
        -e )  RUNEMRUN=on;;
        -d )  DEBUG=on;;
        -j )  shift
              JX="-j$1"
              ;;
        -* )  usage
              exit 1
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
BUILD_TYPE="Release"
ASSERT=0

if test "x$RUNEMRUN" = "xon"; then
    FLAGS="$FLAGS --emrun";
fi

if test "x$DEBUG" = "xon"; then
    FLAGS="$FLAGS -O0 -g";
    BUILDFLAGS="-O2 -g"
    ASSERT=1
elif test "x$XDEBUG" = "xon"; then
    FLAGS="$FLAGS -O0 -g4 --llvm-lto 1"
    BUILDFLAGS="-O0 -g4"
    BUILD_TYPE="Debug"
    ASSERT=1
else
    FLAGS="$FLAGS -Oz --llvm-lto 1";
    BUILDFLAGS="-Oz"
fi

DRAFTER_PATH="ext/protagonist/drafter"

(
  cd "$DRAFTER_PATH"
  emconfigure $PY ./configure
  CFLAGS=${BUILDFLAGS} CXXFLAGS=${BUILDFLAGS} emmake make $JX test-libdrafter BUILDTYPE=$BUILD_TYPE
)

(
    emconfigure $PY ./configure && \
    cd build && \
    CFLAGS=${BUILDFLAGS} CXXFLAGS=${BUILDFLAGS} emmake make $JX libdrafterjs  BUILDTYPE=$BUILD_TYPE
)

mkdir -p lib

em++ $FLAGS "build/out/$BUILD_TYPE/libdrafterjs.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libdrafter.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libsnowcrash.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libsundown.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libmarkdownparser.a" \
     -s EXPORTED_FUNCTIONS="['_drafter_init_parse_options', '_drafter_free_parse_options', '_drafter_set_name_required', '_drafter_init_serialize_options', '_drafter_free_serialize_options', '_drafter_set_sourcemaps_included', '_drafter_set_format', '_drafter_free_result', '_c_serialize_json_options', '_c_buffer_ptr', '_c_buffer_string', '_c_free_buffer_ptr', '_c_parse_to', '_c_validate_to']" \
     -s DISABLE_EXCEPTION_CATCHING=0 \
     -s EXPORTED_RUNTIME_METHODS="['stringToUTF8', 'getValue', 'Pointer_stringify', 'lengthBytesUTF8', 'UTF8ToString']" \
     -s ASSERTIONS=${ASSERT} \
     -s DOUBLE_MODE=0 \
     -s ALLOW_MEMORY_GROWTH=1 \
     -s NO_EXIT_RUNTIME=1 \
     -s INVOKE_RUN=0 \
     -s PRECISE_I64_MATH=0 \
     -s INLINING_LIMIT=50 \
     -s NO_FILESYSTEM=1 \
     -s NODEJS_CATCH_EXIT=0 \
     -s ELIMINATE_DUPLICATE_FUNCTIONS=1 \
     -s AGGRESSIVE_VARIABLE_ELIMINATION=1 \
     -s WASM=0 \
     -o lib/drafter.js  \
     --pre-js generated/pre.js \
     --post-js generated/post.js

em++ $FLAGS --memory-init-file 0 \
     "build/out/$BUILD_TYPE/libdrafterjs.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libdrafter.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libsnowcrash.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libsundown.a" \
     "$DRAFTER_PATH/build/out/$BUILD_TYPE/libmarkdownparser.a" \
     -s EXPORTED_FUNCTIONS="['_drafter_init_parse_options', '_drafter_free_parse_options', '_drafter_set_name_required', '_drafter_init_serialize_options', '_drafter_free_serialize_options', '_drafter_set_sourcemaps_included', '_drafter_set_format', '_drafter_free_result', '_c_serialize_json_options', '_c_buffer_ptr', '_c_buffer_string', '_c_free_buffer_ptr', '_c_parse_to', '_c_validate_to']" \
     -s DISABLE_EXCEPTION_CATCHING=0 \
     -s EXPORTED_RUNTIME_METHODS="['stringToUTF8', 'getValue', 'Pointer_stringify', 'lengthBytesUTF8', 'UTF8ToString']" \
     -s ASSERTIONS=${ASSERT} \
     -s ALLOW_MEMORY_GROWTH=1 \
     -s NO_EXIT_RUNTIME=1 \
     -s INVOKE_RUN=0 \
     -s PRECISE_I64_MATH=0 \
     -s DOUBLE_MODE=0 \
     -s INLINING_LIMIT=50 \
     -s NO_FILESYSTEM=1 \
     -s NODEJS_CATCH_EXIT=0 \
     -s ELIMINATE_DUPLICATE_FUNCTIONS=1 \
     -s AGGRESSIVE_VARIABLE_ELIMINATION=1 \
     -s WASM=0 \
     -o lib/drafter.nomem.js \
     --pre-js generated/pre.js \
     --post-js generated/post.js
