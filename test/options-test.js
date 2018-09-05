var assert = require('chai').assert;
var path = require('path');
var fs = require('fs');
var drafter = require('../lib/drafter.nomem.js');

var fixture_path = path.join(__dirname, '../ext/protagonist/test/fixtures/sample-api.apib');
var expected_err = require('../ext/protagonist/test/fixtures/sample-api-error.json');

describe('Requiring Blueprint name with sourcemaps', function () {
  var refract_err = null;

  before(function (done) {
    fs.readFile(fixture_path, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      drafter.parse(data, { requireBlueprintName: true, generateSourceMap: true }, function (err, result) {
        // if (err) {
        //   return done(err);
        // }

        refract_err = result;
        done();
      });
    });
  });

  it('conforms to the refract spec', function () {
    assert.deepEqual(refract_err, expected_err);
  });
});

describe('Requiring Blueprint name without sourcemaps', function () {
  var refract_err = null;

  before(function (done) {
    fs.readFile(fixture_path, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      drafter.parse(data, { requireBlueprintName: true, generateSourceMap: false }, function (err, result) {
        // if (err) {
        //   return done(err);
        // }

        refract_err = result;
        done();
      });
    });
  });

  it('conforms to the refract spec', function () {
    assert.deepEqual(refract_err, expected_err);
  });
});

describe('Requiring Blueprint name with sourcemaps using sync', function () {
  var refract_err = null;

  before(function (done) {
    fs.readFile(fixture_path, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      refract_err = drafter.parseSync(data, { requireBlueprintName: true, generateSourceMap: true });
      done();
    });
  });

  it('conforms to the refract spec', function () {
    assert.deepEqual(refract_err, expected_err);
  });
});

describe('Requiring Blueprint name without sourcemaps using sync', function () {
  var refract_err = null;

  before(function (done) {
    fs.readFile(fixture_path, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      refract_err = drafter.parseSync(data, { requireBlueprintName: true, generateSourceMap: false });
      done();
    });
  });

  it('conforms to the refract spec', function () {
    assert.deepEqual(refract_err, expected_err);
  });
});

describe('Requiring Blueprint name with validate', function () {
  var refract_err = null;

  before(function (done) {
    fs.readFile(fixture_path, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      drafter.validate(data, function (err, result) {
        if (err) {
          return done(err);
        }

        refract_err = result;
        done();
      });
    });
  });

  it('conforms to the refract spec', function () {
    assert.deepEqual(refract_err, expected_err);
  });
});

describe('Requiring Blueprint name with validate sync', function () {
  var refract_err = null;

  before(function (done) {
    fs.readFile(fixture_path, 'utf8', function (err, data) {
      if (err) {
        return done(err);
      }

      refract_err = drafter.validateSync(data);
      done();
    });
  });

  it('conforms to the refract spec', function () {
    assert.deepEqual(refract_err, expected_err);
  });
});
