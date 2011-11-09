require.paths.unshift "#{__dirname}/../../public/js/"

jsdom = require 'jsdom'
global.jQuery = global.$ = require 'jquery'
require 'underscore'

global.window = jsdom.jsdom().createWindow()
global.document = global.window.document

global.Backbone = require.call(global, 'backbone')
