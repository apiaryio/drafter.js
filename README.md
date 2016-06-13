![logo](https://raw.github.com/apiaryio/api-blueprint/master/assets/logo_apiblueprint.png)

# drafter.js [![Circle CI](https://circleci.com/gh/apiaryio/drafter.js/tree/master.svg?style=shield)](https://circleci.com/gh/apiaryio/drafter.js/tree/master)

Snowcrash parser harness

`drafter.js` is a pure JavaScript version of the `drafter` library. It exposes
a single `parse` function which takes an API Blueprint string and options as
input and returns the parse result. It is built from the C++ sources using
[emscripten](http://kripken.github.io/emscripten-site/). It's API compatible
with [Protagonist](https://github.com/apiaryio/protagonist), the Drafter Node
binding.

## Installation

drafter.js can be installed from NPM, or it can be downloaded from the [releases
page](https://github.com/apiaryio/drafter/releases).

```shell
$ npm install drafter.js
```

## Usage

### Node

If you've installed drafter.js via NPM and using drafter.js in Node, you can
require it via:

```javascript
var drafter = require('drafter.js')
```

*Node versions supported*: >=0.12

It works on 0.10 too but without any guarantees and expect it to be
significantly slower.

### Web Browser

If instead, you are using drafter.js in a Browser. You can include it via the
HTML script tag.

```html
<script src="./drafter.js"></script>
<script src="./drafter.js.mem"></script>
```

### API

Once you've included drafter.js, you can parse an API Blueprint:

```javascript
try {
  var res = drafter.parse('# API Blueprint...', {exportSourcemap: true});
  console.log(res);
} catch (err) {
  console.log(err);
}
```

Supported options:

- `exportSourcemap`: Set to export sourcemap information.
- `json`: Set to `false` to disable parsing of the JSON data. You will
  instead get a JSON string as the result.
- `requireBlueprintName`: Set to generate an error if the blueprint is
  missing a title.
- `type`: Either `refract` (default) or `ast`.

#### Protagonist

`drafter.js` can serve as drop in replacement for
[protagonist](https://github.com/apiaryio/protagonist), it supports
the same API. This allows you to prefer protagonist and fallback to drafter.js.
Protagonist will provide you with higher performance while parsing blueprints,
however since protagonist is a binding it may be tricky to install.

```javascript
try {
  var protagonist = require('protagonist');
} catch (e) {
  console.log("protagonist not found, using drafter.js.");
  var protagonist = require('drafter.js');
}

protagonist.parse(data, options, function(err, result) {
  if (err) {
    console.log(JOSN.stringify(err));
  }

  console.log(JSON.stringify(data));
});
```
is possible. Protagonist `parseSync` function is available too.

### Build drafter.js

*Unfortunately building drafter.js works only on a *nix environment at the
moment.*

1. Building is easy using [Docker](https://www.docker.com/).

2. Build

    ```shell
    $ docker pull "apiaryio/emcc:1.36"
    $ docker run -v $(pwd):/src -t apiaryio/emcc:1.36 emcc/emcbuild.sh
    ```
    or with `npm`
    ```shell
    $ npm run build
    ```

3. Check out the `./scripts/test.js` and `./scripts/test.html` files for
   example usage. You can also use `npm install` and then `npm test` to run the
   tests.

The resulting stand-alone library `drafter.js` is in the `./lib` directory.
Don't forget to serve the `drafter.js.mem` file as it is required by
`drafter.js`. There is also a single-file version in `drafter.nomem.js` that
can be used, but it may take longer to load in a web browser
environment. It is the default for node.js enviroment.

To get a debug version or version enabled to be used with `emrun` run
the `emcbuild.sh` script it with `-d` or `-e` respectively.

#### Squeeze the size

If you want to squeeze the size to a minimum install
[uglify-js](https://github.com/mishoo/UglifyJS2) and try running
`uglifyjs lib/drafter.js -o drafter.js -c;`, this will use
`uglify-js` with compression, beware that this might cause some
errors, if you encounter them try `drafter.js` without it to verify
that it is caused by `uglify-js` and report it please.

## License
MIT License. See the [LICENSE](https://github.com/apiaryio/drafter.js/blob/master/LICENSE) file.
