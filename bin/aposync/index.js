#!/usr/bin/env node

'use strict'

const child_process = require('child_process')

// console.log(__dirname)
// console.log(process.cwd())

let arg = []
if (process.argv.length > 2)
	arg = process.argv.slice(2)

// child_process.exec('pwd')
child_process.execFileSync(`${process.cwd()}/node_modules/@bohemicastudio/apostrophe-sync/aposync.sh`, arg, {stdio: 'inherit'})
