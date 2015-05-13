# Browserify entry point for the global.js bundle (yay CoffeeScript!)
$ = require('jquery')
dreamhorn = require('./dreamhorn')
require('./game')
$ ->
  dreamhorn.init $('#main')

console.log 'main.coffee loaded!'
