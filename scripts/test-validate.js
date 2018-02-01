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

var testRun = {
  total: 0,
  pass: 0,
  fail: 0,
  jsTime: 0,
  prtgTime: 0,
  cppTime: 0
};

var options = {};

/*
 * Convert a duration from `process.hrtime()` into milliseconds.
 */
function ms(duration) {
  return duration[0] * 1000 + duration[1] / 1e6;
}

/*
 * Tests a single file against the output of protagonist
 */
function testFile(filename, done) {
  console.log(filename);
  testRun.total++;
  async.series({
    protagonist: function (callback) {
      fs.readFile(filename, 'utf8', function (err, data) {
        var start = process.hrtime();
        protagonist.validate(data, options, function (error, result) {
          var duration = process.hrtime(start);
          callback(null, {
            output: result,
            duration: ms(duration),
            error: error
          });
        });
      });
    },
    js: function (callback) {
      fs.readFile(filename, 'utf8', function (err, data) {
        var start = process.hrtime();
        drafter.validate(data, options, function (error, result) {
          var duration = process.hrtime(start);
          callback(null, {
            output: result,
            duration: ms(duration),
            error: error
          });
        });
      });
    }
  }, function (err, results) {
    // Parsing both ways has completed. Now we compare them!
    if (err) return done(err);

    try {
      if (!results.js.error && !results.protagonist.error) {
        assert.deepEqual(results.js.output, results.protagonist.output, 'Parsed correctly as expected');
      } else if (results.js.error && results.protagonist.error) {
        if (results.js.error.result) {
          assert.deepEqual(results.js.error.result, results.protagonist.error.result, 'JS and Protagonist both failed.');
        } else{
          throw Error("JS without result: " + JSON.stringify(results.js.error));
        }
      } else if (results.js.error) {
        console.log(results.protagonist.error);
        console.log(results.protagonist.output);
        throw Error("JS parsing failed: " + JSON.stringify(results.js.error));
      } else {
        throw Error("Protagonist parsing failed: " + JSON.stringify(results.protagonist.error));
      }

      var durationDiff = results.js.duration / results.protagonist.duration;
      console.log('OK ' + filename + ' JS:' + parseInt(results.js.duration) + 'ms P:' + parseInt(results.protagonist.duration) + 'ms');
      testRun.pass++;
    } catch (err) {
      console.log('FAIL ' + filename);

      if (!results.js.ouptut) {
        console.log(chalk['red'](err));
      } else {
        // Get a smart diff and display only the parts that have changed.
        var diff = jsdiff.diffJson(results.js.output, results.protagonist.output);
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

    testRun.prtgTime += results.protagonist.duration;
    testRun.jsTime += results.js.duration;

    done();
  });
}

console.log("Validate Test ....\n");

/*
 * Loop through all the files, test them, then print a report.
 */
fixtures = [].concat(
  glob.sync('ext/drafter/test/**/*.apib'),
  glob.sync('scripts/fixtures/*.apib')
);

async.eachLimit(fixtures, 1, testFile, function (err) {
  if (err) {
    console.log(err);
    console.log();
  }

  console.log('\nTest run result:\n================');
  console.log('Total:  ' + testRun.total);
  console.log('Passed: ' + testRun.pass);
  console.log('Failed: ' + testRun.fail);
  console.log('Average JS speed: ' + (testRun.jsTime / testRun.prtgTime).toFixed(1) + ' times slower than Protagonist\n');

  process.exit(testRun.fail > 0 ? -1 : 0);
});

