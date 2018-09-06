var assert = require('chai').assert;
var path = require('path');
var fs = require('fs');
var drafter = require('../lib/drafter.nomem.js');

var valid_fixture = path.join(__dirname, '../ext/protagonist/test/fixtures/sample-api.apib');
var warning_fixture = path.join(__dirname, '../ext/protagonist/test/fixtures/invalid-api-warning.apib');
var error_fixture = path.join(__dirname, '../ext/protagonist/test/fixtures/invalid-api-error.apib');

var warning_refract = require('../ext/protagonist/test/fixtures/invalid-api-warning.json');
var error_refract = require('../ext/protagonist/test/fixtures/invalid-api-error.json');

describe('Validate Blueprint with error - Sync', function () {
  var parsed = null;

  before(function (done) {
    fs.readFile(error_fixture, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      parsed = drafter.validateSync(data);
      done();
    });
  });

  it('Result contains annotations only', function () {
    assert.deepEqual(parsed, error_refract);
  });
});

describe('Validate Blueprint with warning - Sync', function () {
  var parsed = null;

  before(function (done) {
    fs.readFile(warning_fixture, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      parsed = drafter.validateSync(data);
      done();
    });
  });

  it('Result contains annotations only', function () {
    assert.deepEqual(parsed, warning_refract);
  });
});

describe('Validate valid Blueprint - Sync', function () {
  var parsed = 1;

  before(function (done) {
    fs.readFile(valid_fixture, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      parsed = drafter.validateSync(data);
      done();
    });
  });

  it('will return null', function () {
    assert.isNull(parsed);
  });
});

describe('Validate Blueprint with error - Async', function () {
  var parsed = null;

  before(function (done) {
    fs.readFile(error_fixture, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      drafter.validate(data, {}, function (err, result) {
        if (err) {
          return done(err);
        }

        parsed = result;
        done();
      });
    });
  });

  it('Result contains annotations only', function () {
    assert.deepEqual(parsed, error_refract);
  });
});

describe('Validate Blueprint with warning - Async', function () {
  var parsed = null;

  before(function (done) {
    fs.readFile(warning_fixture, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      drafter.validate(data, {}, function (err, result) {
        if (err) {
          return done(err);
        }

        parsed = result;
        done();
      });
    });
  });

  it('Result contains annotations only', function () {
    assert.deepEqual(parsed, warning_refract);
  });
});

describe('Validate valid Blueprint - Async', function () {
  var parsed = 1;

  before(function (done) {
    fs.readFile(valid_fixture, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      drafter.validate(data, {}, function (err, result) {
        if (err) {
          return done(err);
        }

        parsed = result;
        done();
      });
    });
  });

  it('will return null', function () {
    assert.isNull(parsed);
  });
});
