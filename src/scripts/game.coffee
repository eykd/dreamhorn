# Browserify entry point for the page.js bundle (yay JavaScript!)

$ = require('jquery')
_ = require('underscore')
# global.js already contains jQuery, so in our config.js file, we
# are exposing it to other files like this one in the `require` array.
# Also in config.js, jquery is listed in `external` array for this bundle.
# This combination lets this file use the jquery module bundled with
# global.js, instead of including it twice!

messageTemplate = _.template "<p class='love-letter'>Made with <%= feels %> at <a href='<%= url %>'><%= bestCompanyEvar %>!</a></p>"

message = messageTemplate
  bestCompanyEvar: 'Viget'
  feels: '♥'
  url: 'http:#viget.com'

$('body').append(message)

console.log 'game.coffee loaded!'
