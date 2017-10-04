/*jslint indent: 2, maxlen: 80, continue: false, unparam: false, node: true */
/* -*- tab-width: 2 -*- */
'use strict';
// purpose: Help the kiss CLI resolve packages relative to this one.
console.log(process.argv.slice(2).map(require.resolve).join('\n'));
