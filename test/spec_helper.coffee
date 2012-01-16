#require.paths.unshift "#{__dirname}/../../public/js/"

global.jsDirPath = "#{__dirname}/../public/js"

jsdom = require 'jsdom'
should = require 'should'
global.sinon = require 'sinon'

global.jQuery = global.$ = require 'jquery'
global._ = require 'underscore'

global.window = jsdom.jsdom().createWindow()
global.document = global.window.document

global.Backbone = require.call(global, 'backbone')
global.context = global.describe
