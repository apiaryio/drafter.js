# drafter.js Changelog

## 2.6.0

### Enhancements

- Added `validate` and `validateSync` to just return the warnings and errors
  after parsing a blueprint.

## 2.5.2

This update now uses Drafter 3.1.3. Please see [Drafter
3.1.3](https://github.com/apiaryio/drafter/releases/tag/v3.1.3) for
the list of changes.

## 2.5.1

This update now uses Drafter 3.1.2. Please see [Drafter
3.1.2](https://github.com/apiaryio/drafter/releases/tag/v3.1.2) for
the list of changes.

## 2.5.0

This update now uses Drafter 3.1.1. Please see [Drafter
3.1.1](https://github.com/apiaryio/drafter/releases/tag/v3.1.1) for
the list of changes.

## 2.5.0-pre.0

This update now uses Drafter 3.1.0-pre.0. Please see [Drafter
3.1.0-pre.0](https://github.com/apiaryio/drafter/releases/tag/v3.1.0-pre.0) for
the list of changes.

## 2.4.3

### Bug Fixes

- Fixes an `undefined` exception thrown when the API Bleuprint
  contained Unicode characters due to a missing function 'UTF8ToString'.
  [issue #54](https://github.com/apiaryio/drafter.js/issues/54)


## 2.4.2

### Bug Fixes

- This release ensures that the .gyp and .gypi files are not detected during
  building the NPM package. NPM incorrectly computes the `gypfile` without
  respecting the `.npmignore` file.
  [npm/read-package-json#52](https://github.com/npm/read-package-json/pull/52)


## 2.4.1

### Bug Fixes

- Removes unnecessary files from the NPM package. 2.4.0 included the C++ source
  for Drafter and this causes problems while trying to install the package via
  NPM since it will try and use node-gyp to build the source.


## 2.4.0

### Enhancements

- Substantial performance improvements, parsing blueprints is now much faster.
- drafter.js now follows [Universal Module Definition (UMD)](https://github.com/umdjs/umd).
