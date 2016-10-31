/*
 * Parse an API Blueprint. By default, this will return the result loaded
 * as an object.
 *
 * Options:
 * - `exportSourcemap`: Set to export sourcemap information.
 * - `json`: Set to `false` to disable parsing of the JSON data. You will
             instead get a JSON string as the result.
 * - `requireBlueprintName`: Set to generate an error if the blueprint is
                             missing a title.
 * - `type`: Either `refract` (default) or `ast`.
 */
Module['parse'] = function(blueprint, options, callback) {
  if (false === this.ready) {
    var err = new Error('Module not ready!');
    if (callback) {
      return callback(err, null);
    }
    return err;
  }

  try {

    var chptr = _malloc(4);
    var bufferLen = lengthBytesUTF8(blueprint) + 1;
    var buffer = _malloc(bufferLen);
    var parseOptions = 0;
    var astType = 1;

    stringToUTF8(blueprint, buffer, bufferLen);

    if (options) {
      if (options.exportSourcemap || options.generateSourceMap) {
        parseOptions |= (1 << 2);
      }

      if (options.requireBlueprintName) {
        parseOptions |= (1 << 1);
      }

      switch (options.type) {
      case 'ast':
        astType = 0;
        break;
      case 'refract':
        astType = 1;
        break;
      case undefined:
        break;
      default:
        var err = new Error('Unknown type option ' + options.type);
        if (callback) {
          return callback(err, null);
        }
        throw err;
      }
    }

    var res = _c_parse(buffer, parseOptions, astType, chptr);

    _free(buffer);

    var ptrstr = getValue(chptr, '*');
    var output = Pointer_stringify(ptrstr);

    _free(ptrstr);
    _free(chptr);

  } catch (ex) {

    if (callback) {
      return callback(ex, null);
    }
    throw ex;
  }

  if (res) {
    var err = new Error('Error parsing blueprint!');
    err.result = (options && options.json === false) ? output : JSON.parse(output);
    if (callback) {
      return callback(err, err.result);
    }
    throw err;
  }

  if (callback) {
    return callback(null, (options && options.json === false) ? output : JSON.parse(output));
  }
  return (options && options.json === false) ? output : JSON.parse(output);
};

Module['parseSync'] = function(blueprint, options) {
  return Module.parse(blueprint, options);
};

/*
 * Validate an API Blueprint.
 *
 * Options:
 * - `json`: Set to `false` to disable parsing of the JSON data. You will
             instead get a JSON string as the result.
 * - `requireBlueprintName`: Set to generate an error if the blueprint is
                             missing a title.
 */
Module['validate'] = function(blueprint, options, callback) {
  if (false === this.ready) {
    var err = new Error('Module not ready!');
    if (callback) {
      return callback(err, null);
    }
    return err;
  }

  try {

    var chptr = _malloc(4);
    var bufferLen = lengthBytesUTF8(blueprint) + 1;
    var buffer = _malloc(bufferLen);
    var parseOptions = 0;
    var output = null;

    if (options && options.requireBlueprintName) {
      parseOptions |= (1 << 1);
    }

    stringToUTF8(blueprint, buffer, bufferLen);

    var res = _c_validate(buffer, parseOptions, chptr);
    _free(buffer);

    if (res) {
      var ptrstr = getValue(chptr, '*');
      output = (options && options.json === false) ? Pointer_stringify(ptrstr) : JSON.parse(Pointer_stringify(ptrstr));
      _free(ptrstr);
    }
    _free(chptr);

  } catch (ex) {

    if (callback) {
      return callback(ex, null);
    }
    throw ex;
  }

  if (callback) {
    return callback(null, output);
  }
  return output;
};

Module['validateSync'] = function(blueprint, options) {
  return Module.validate(blueprint, options);
};
