#!/usr/bin/env node

'use strict'

const { exec } = require('child_process')

console.log(__dirname)
console.log(process.cwd())

let arg = ''
if (process.argv.length > 2)
	arg = ' ' + process.argv.slice(2).join(' ');

exec('pwd')

exec(`${process.cwd()}/node_modules/@bohemicastudio/apostrophe-sync/aposync.sh`+arg, function (error, stdout, stderr) {
	console.error(error)
	console.log(stdout)
	console.log(stderr)
})
