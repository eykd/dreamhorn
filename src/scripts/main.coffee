# Browserify entry point for the global.js bundle (yay CoffeeScript!)
$ = window.$ = window.jQuery = require('jquery')
require('velocity-animate')
dreamhorn = window.dreamhorn = require('./dreamhorn')
require('./game')
$ ->
  dreamhorn.init $('#main')

console.log 'main.coffee loaded!'
