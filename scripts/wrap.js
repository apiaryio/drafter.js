#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var umd = require('umd');
var mkdirp = require('mkdirp').sync;

var generatedDir = path.join(__dirname, '../generated/');
var srcDir = path.join(__dirname, '../src/');
var pre = fs.readFileSync(srcDir + 'pre.js');
var post = fs.readFileSync(srcDir + 'post.js');

pre = umd.prelude('drafter') + pre;
post += '\nreturn Module;' +umd.postlude('drafter');

mkdirp(generatedDir);

fs.writeFileSync(generatedDir + 'pre.js', pre);
fs.writeFileSync(generatedDir + 'post.js', post);
