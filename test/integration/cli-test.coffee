{assert} = require('chai')
{exec} = require('child_process')
fs = require 'fs'

CMD_PREFIX = ''

stderr = ''
stdout = ''
exitStatus = null
requests = []

# Execute a CLI command
# Credit: This code is originally taken from Dredd
execCommand = (cmd, callback) ->
  stderr = ''
  stdout = ''
  exitStatus = null

  cli = exec CMD_PREFIX + cmd, (error, out, err) ->
    stdout = out
    stderr = err

    if error
      exitStatus = error.code

  exitEventName = if process.version.split('.')[1] is '6' then 'exit' else 'close'

  cli.on exitEventName, (code) ->
    exitStatus = code if exitStatus == null and code != undefined
    callback(undefined, stdout, stderr, exitStatus)

describe 'Command line interface', () ->
  describe 'parsing valid blueprint', () ->
    before (done) ->
      cmd = './bin/drafter ./test/fixtures/blueprint.apib'

      execCommand cmd, done

    it 'should exit with status 0', () ->
      assert.equal exitStatus, 0

    it 'stdout should contain the parse result fixture', () ->
      ast_fixture = require '../fixtures/blueprint.parseresult.json'
      expected = JSON.stringify ast_fixture, null, 2
      expected += '\n'

      assert.equal stdout, expected

  describe 'parsing blueprint with source map', () ->
    before (done) ->
      cmd = './bin/drafter -s ./test/fixtures/blueprint.apib'

      execCommand cmd, done

    it 'should exit with status 0', () ->
      assert.equal exitStatus, 0

    it 'stdout should contain the source map parser result fixture', () ->
      ast_fixture = require '../fixtures/blueprint.parseresult+sourcemap.json'
      expected = JSON.stringify ast_fixture, null, 2
      expected += '\n'

      assert.equal stdout, expected

  describe 'parsing invalid blueprint', () ->
    before (done) ->
      cmd = './bin/drafter ./test/fixtures/invalid.apib'

      execCommand cmd, done

    it 'should exit with status 1', () ->
      assert.equal exitStatus, 1

    it 'stderr should contain an error message', () ->
      assert.include stderr, 'Error:'
