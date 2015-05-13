'use strict';

$ = require('jquery')
dreamhorn = require('./dreamhorn')

dreamhorn.dispatcher.on "hide:begin-button", ($el) ->
  $el.slideUp()


dreamhorn.dispatcher.on "show:situation", ($el) ->
  $el.slideDown()
  $('html, body').animate({
      scrollTop: $el.offset().top
  }, 2000);



dreamhorn.situation 'begin',
  content: """

  Hurrying through the rainswept November night, you're glad to see the bright
  lights of the Opera House. It's surprising that there aren't more people
  about but, hey, what do you expect in a cheap demo game...?

  """


console.log "game.coffee loaded!"


