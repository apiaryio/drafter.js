/*
 *  Drafter.js async performance test
 */

var Drafter = require('../../lib/drafter');
var async = require('async');
var fs = require('fs');

// Total number of runs
var totalRuns = 100;
var blueprint = fs.readFileSync('./test/fixtures/dataStructures.apib', 'utf8');

function runAsyncTest() {
  var pool = [];

  var tick = 0;

  var tickCB = function() {
    tick++;
    process.stdout.write('T');
  };

  for (var i = 0; i < totalRuns; ++i) {
    pool[i] = function (callback) {

      var drafter = new Drafter({ "requireBlueprintName": true, "exportSourcemap": true });
      drafter.make(blueprint, function(err, result) {
        process.nextTick(tickCB);
        if (err) {
          console.error(JSON.stringify(err, null, 2));
          process.stdout.write('x');
          return callback(err);
        }

        process.stdout.write('.');

        callback();
      });
    }
  }

  var startTime = new Date().getTime();

  async.parallel(pool, function (err) {
    if (err) {
      console.error(err);
      process.exit(err.code);
    }

    var endTime = new Date().getTime();
    var time = endTime - startTime;
    console.log('\nOk. (' + time + 'ms)');
  });
}

runAsyncTest();
