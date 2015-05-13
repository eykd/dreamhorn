'use strict';

dreamhorn = require('./dreamhorn')


DURATION = 500

dreamhorn.dispatcher.on "hide:begin-button", ($el) ->
  $el.velocity('slideUp', {duration: DURATION})

dreamhorn.dispatcher.on "show:situation", ($el) ->
  $el.velocity('fadeIn', {duration: DURATION})
     .velocity('scroll', {duration: 1000})

# dreamhorn.dispatcher.on "hide:situation", ($el) ->
#   $el.velocity('slideUp', {duration: DURATION})
