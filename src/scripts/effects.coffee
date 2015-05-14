'use strict';

dreamhorn = require('./dreamhorn')


dreamhorn.dispatcher.on "remove:begin-button", ($el, duration) ->
  $el.velocity('slideUp', {duration: duration})

dreamhorn.dispatcher.on "show:situation", ($el, duration) ->
  $el.velocity('fadeIn', {duration: duration})
     .velocity('scroll', {duration: 1000})

dreamhorn.dispatcher.on "remove:situation", ($el, duration) ->
  $el.velocity('slideUp', {duration: duration})
