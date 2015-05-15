'use strict';

_ = require('lodash')
ramjet = require('ramjet')

dreamhorn = require('./dreamhorn')

DURATION = 500

dreamhorn.dispatcher.on "expand:title", ($el) ->
  _.delay(
    (() -> $el.removeClass('page-header').addClass('jumbotron')),
    DURATION * 2
  )

dreamhorn.dispatcher.on "reduce:title", ($el) ->
  _.delay(
    (() -> $el.removeClass('jumbotron').addClass('page-header')),
    DURATION * 2
  )

dreamhorn.dispatcher.on "remove:begin-button", ($el) ->
  $.Velocity($el.get(0), 'slideUp', {duration: DURATION}).then ->
    $el.remove()

dreamhorn.dispatcher.on "show:situation", ($el, $trigger) ->
  if $trigger
    ramjet.transform $trigger.get(0), $el.get(0),
      duration: duration
  else
    $el.velocity('slideDown', {duration: DURATION})

  $el.velocity('scroll', {duration: DURATION})

dreamhorn.dispatcher.on "remove:situation", ($el, $trigger) ->
  $el.velocity('slideUp', {duration: duration})
