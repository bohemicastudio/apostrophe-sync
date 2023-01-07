#!/usr/bin/env node

'use strict'

const { exec } = require('child_process')

exec(`${process.cwd()}/node_modules/@bohemicastudio/apostrophe-sync/aposync.sh`, function (error, stdout, stderr) {
	console.error(error)
	console.log(stdout)
	console.log(stderr)
})
