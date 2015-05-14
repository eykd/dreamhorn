# Browserify entry point for the global.js bundle (yay CoffeeScript!)
$ = window.$ = window.jQuery = require('jquery')
require('velocity-animate')
dreamhorn = window.dreamhorn = require('./dreamhorn')
require('./game')
config = require('./config')

$ ->
  config.el = $('#main').get(0)
  dreamhorn.init config

console.log 'main.coffee loaded!'
