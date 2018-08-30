#!/usr/bin/env node

var assert = require('chai').assert;
var async = require('async');
var chalk = require('chalk');
var exec = require('child_process').exec;
var fs = require('fs');
var glob = require('glob');
var jsdiff = require('diff');
var path = require('path');
var drafter = require('../lib/drafter.nomem.js');

var protagonist = null;
try {
  protagonist = require('protagonist');
} catch (err) {
  console.log('Skipping protagonist tests. Use `npm install protagonist` to run them.')
}

var DRAFTER = path.join('ext', 'protagonist', 'drafter', 'bin', 'drafter');

var testRun = {
  total: 0,
  pass: 0,
  fail: 0,
  jsTime: 0,
  prtgTime: 0,
  cppTime: 0
};

/*
 * Convert a duration from `process.hrtime()` into milliseconds.
 */
function ms(duration) {
  return duration[0] * 1000 + duration[1] / 1e6;
}

/*
 * Tests a single file with a single serialization format against the output
 * of the `drafter` executable.
 */
function testSerialization(filename, done) {
  testRun.total++;

  async.series({
    // Get the C++ drafter executable output
    cpp: function (callback) {
      var cmd = DRAFTER + ' -f json ' + filename;
      var start = process.hrtime();

      exec(cmd, function (err, stdout, stderr) {
        var duration = process.hrtime(start);

        try {
          callback(null, {
            output: stdout ? JSON.parse(stdout) : null,
            duration: ms(duration),
            error: err
          });
        } catch (jsonErr) {
          // Probably couldn't parse the output as JSON... hmm.
          callback(jsonErr);
        }
      });
    },
    protagonist: function (callback) {
      if (!protagonist) {
        // No protagonist module (which is optional), so skip this!
        return callback(null, {
          result: '',
          duration: 0,
          error: null
        });
      }

      fs.readFile(filename, 'utf8', function (err, data) {
        var start = process.hrtime();

        protagonist.parse(data, {}, function (caughtErr) {
          var duration = process.hrtime(start);
          // We really only care about timing info here, so we ignore the result
          callback(null, {
            result: '',
            duration: ms(duration),
            error: caughtErr
          });
        });
      });
    },
    // Get the drafter.js output
    js: function (callback) {
      fs.readFile(filename, 'utf8', function (err, data) {
        var result;
        var caughtError;
        var start = process.hrtime();

        try {
          result = drafter.parse(data, {});
        } catch (parseErr) {
          result = parseErr.result;
          caughtError = parseErr;
        }

        var duration = process.hrtime(start);

        callback(null, {
          output: result,
          duration: ms(duration),
          error: caughtError
        });
      });
    }
  }, function (err, results) {
    // Parsing both ways has completed. Now we compare them!
    if (err) return done(err);

    try {
      if (!results.js.error && !results.cpp.error) {
        assert.deepEqual(results.js.output, results.cpp.output, 'Parsed correctly as expected');
      } else if (results.js.error && results.cpp.error) {
        if (results.js.error.result) {
          assert.deepEqual(results.js.error.result, results.cpp.output, 'JS and CPP both failed.');
        } else{
          throw Error("JS without result: " + JSON.stringify(results.js.error));
        }
      } else if (results.js.error) {
        throw Error("JS parsing failed: " + JSON.stringify(results.js.error));
      } else {
        throw Error("CPP parsing failed: " + JSON.stringify(results.cpp.error));
      }

      var durationDiff = results.js.duration / results.cpp.duration;
      console.log('OK ' + filename + ' JS:' + parseInt(results.js.duration) + 'ms P:' + parseInt(results.protagonist.duration) + 'ms CPP:' + parseInt(results.cpp.duration) + 'ms (' + parseInt(durationDiff * 100) + '%)');
      testRun.pass++;
    } catch (err) {
      console.log('FAIL ' + filename);

      if (!results.js.ouptut) {
        console.log(chalk['red'](err));
      } else {
        // Get a smart diff and display only the parts that have changed.
        var diff = jsdiff.diffJson(results.js.output, results.cpp.output);

        if (!diff.length) {
          console.log(err);
        }

        diff.forEach(function (part) {
          if (part.added || part.removed) {
            var color = part.added ? 'green' : 'red';
            console.log(chalk[color](part.value));
          }
        });
      }
      testRun.fail++;
    }

    testRun.cppTime += results.cpp.duration;
    testRun.prtgTime += results.protagonist.duration;
    testRun.jsTime += results.js.duration;

    done();
  });
}

console.log("Parse Test ....\n");

/*
 * Loop through all the files, test them, then print a report.
 */
fixtures = [].concat(
  glob.sync('ext/protagonist/drafter/test/**/*.apib'),
  glob.sync('scripts/fixtures/*.apib')
);

async.eachLimit(fixtures, 1, testSerialization, function (err) {
  if (err) {
    console.log(err);
    console.log();
  }

  console.log('\nTest run result:\n================');
  console.log('Total:  ' + testRun.total);
  console.log('Passed: ' + testRun.pass);
  console.log('Failed: ' + testRun.fail);
  console.log('Average JS speed: ' + (testRun.jsTime / testRun.cppTime).toFixed(1) + ' times slower than C++ and ' + (testRun.jsTime / testRun.prtgTime).toFixed(1) + ' times slower than Protagonist\n');

  process.exit(testRun.fail > 0 ? -1 : 0);
});
