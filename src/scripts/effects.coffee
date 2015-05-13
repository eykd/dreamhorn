'use strict';

dreamhorn = require('./dreamhorn')


DURATION = 1500

dreamhorn.dispatcher.on "hide:begin-button", ($el) ->
  $el.velocity('slideUp', {duration: DURATION})

dreamhorn.dispatcher.on "show:situation", ($el) ->
  $el.velocity('slideDown', {duration: DURATION})
     .velocity('scroll', {duration: DURATION})

dreamhorn.dispatcher.on "hide:situation", ($el) ->
  $el.velocity('slideUp', {duration: DURATION})
