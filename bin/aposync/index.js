#!/usr/bin/env node

'use strict'

const { exec } = require('child_process')

console.log(__dirname)
console.log(process.cwd())

exec('pwd')

exec(`${process.cwd()}/apostrophe-sync/aposync.sh`, function (error, stdout, stderr) {
	console.error(error)
	console.log(stdout)
	console.log(stderr)
})
