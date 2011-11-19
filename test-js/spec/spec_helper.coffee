require.paths.unshift "#{__dirname}/../../public/js/"

jsdom = require 'jsdom'
global.jQuery = global.$ = require 'jquery'
global._ = require 'underscore'

global.window = jsdom.jsdom().createWindow()
global.document = global.window.document

global.Backbone = require.call(global, 'backbone')
global.context = global.describe
