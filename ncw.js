/*jslint indent: 2, maxlen: 80, continue: false, unparam: false, node: true */
/* -*- tab-width: 2 -*- */
'use strict';

var EX = module.exports, async = require('async'),
  fs = require('fs'), pathLib = require('path'),
  userHomeDir = (process.env.HOME || '/#/E_NO_USERHOME'),
  cfgDir = pathLib.join(userHomeDir, '.config/nodejs/npm'),
  rcdir = require('rcdir'), ceson = require('ceson');


EX.defaultConfig = (function () {
  var env = process.env, httpProxy;
  httpProxy = (env.http_proxy || env.HTTP_PROXY || '');
  return { proxy: httpProxy, 'http-proxy': httpProxy,
    prefix: env.home,
    registry: 'http://registry.npmjs.org/',
    };
}());


EX.runFromCLI = function (argv) {
  argv = (argv || process.argv).slice();
  argv.invokedAs = argv.shift();

  function whenHasConfig(err, cfg) {
    if (err) { throw err; }
    EX.cfg2env(process.env, cfg);
    console.log(cfg);
  }

  return rcdir({ dir: cfgDir, prefix: 'rc', suffix: '.ceson',
    parse: ceson }, whenHasConfig);
};


EX.cfg2env = function (env, cfg) {
  Object.keys(cfg).forEach(function (key) {
    var val = cfg[key];
    key = 'npm_config_' + key;
    if (!val) { return delete env[key]; }
    if (typeof val === 'string') { env[key] = val; }
  });
};




































if (require.main === module) { EX.runFromCLI(); }
