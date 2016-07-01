var fs = require('fs');
var path = require('path');
var drafter = require('../lib/drafter.nomem.js');

/*
 * Convert a duration from `process.hrtime()` into milliseconds.
 */
function ms(duration) {
  return duration[0] * 1000 + duration[1] / 1e6;
}

var filename = process.argv[2];

var options = {
  type: 'ast'
};

fs.readFile(filename, 'utf8', function (err, data) {
  var result;
  var caughtError;
  var start = process.hrtime();
  try {
    result = drafter.parse(data, options);
  } catch (parseErr) {
    result = parseErr.result;
    caughtError = parseErr;
  }
  var duration = process.hrtime(start);

  if (caughtError == undefined) {
    console.log('OK ' + filename + ' ('+ options.type +') ' +  parseInt(ms(duration)) + 'ms');
    console.log(JSON.stringify(result, null, 2));
  }
  else {
    console.log('FAIL ' + filename + ' ('+ options.type +') ' +  parseInt(ms(duration)) + 'ms');
    console.log('Error: ' +  caughtError);
  }
});
