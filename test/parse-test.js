var assert = require('chai').assert;
var glob = require('glob');
var path = require('path');
var fs = require('fs');
var exec = require('child_process').exec;
var drafter = require('../lib/drafter.nomem.js');

// TODO: Run protagonist tests from ext/protagonist installation

var DRAFTER = path.join('ext', 'protagonist', 'drafter', 'bin', 'drafter');

// Loop through all the files, test them, then print a report
var fixtures = [].concat(
  glob.sync('ext/protagonist/drafter/test/**/*.apib'),
  glob.sync('test/fixtures/*.apib')
);

describe('Parse fixture', function () {
  fixtures.forEach(function (fixture) {
    var testName = path.join(path.basename(path.dirname(fixture)), path.basename(fixture));

    describe(testName, function () {
      var cppDuration = 0;
      var cppError = null;
      var cppOutput = null;
      var jsDuration = 0;
      var jsError = null;
      var jsOutput = null;

      it('C++ parser', function (done) {
        var start = process.hrtime();

        exec(`${DRAFTER} -f json ${fixture}`, function (err, stdout, stderr) {
          var duration = process.hrtime(start);

          try {
            if (stdout) {
              cppOutput = JSON.parse(stdout)
            }

            cppError = err;
            cppDuration = duration;
            done();
          } catch (jsonErr) {
            done(jsonErr);
          }
        });
      });

      it('JS parser', function (done) {
        fs.readFile(fixture, 'utf8', function (fileErr, data) {
          if (fileErr) {
            return done(fileErr);
          }

          var start = process.hrtime();

          drafter.parse(data, {}, function (err, result) {
            var duration = process.hrtime(start);

            jsOutput = result;
            jsDuration = duration;
            jsError = err;
            done();
          });
        });
      });

      describe('when compared', function () {
        it('should be good', function () {
          if (!jsError && !cppError) {
            assert.deepEqual(cppOutput, jsOutput);
          } else if (jsError && cppError) {
            assert.isNotNull(jsError.result, 'JS result does not exist');
            assert.deepEqual(jsError.result, cppOutput);
          } else {
            assert.isNull(jsError, 'JS parsing failed');
            assert.isNull(cppError, 'CPP parsing failed');
          }
        });
      });
    });
  });
});
