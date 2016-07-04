# drafter.js Changelog

## 2.4.1

### Bug Fixes

- Removes unnecessary files from the NPM package. 2.4.0 included the C++ source
  for Drafter and this causes problems while trying to install the package via
  NPM since it will try and use node-gyp to build the source.


## 2.4.0

### Enhancements

- Substantial performance improvements, parsing blueprints is now much faster.
- drafter.js now follows [Universal Module Definition (UMD)](https://github.com/umdjs/umd).
