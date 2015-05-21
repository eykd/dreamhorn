'use strict';

_ = require('lodash')
ramjet = require('ramjet')

dreamhorn = require('./dreamhorn')

DURATION = 500

$.Velocity.RegisterEffect 'transition.enter',
  defaultDuration: DURATION * 3
  calls: [
    [{height: 0}, 0.0],
    [{height: '100%'}, 0.33],
    ['transition.expandIn', 0.33, {delay: DURATION}],
    ['scroll', 0.33],
  ]


make_invisible = ($el) ->
  $el.css({visibility: 'hidden'}).show()


dreamhorn.dispatcher.on "expand:title", ($el) ->
  $el.velocity('fadeOut', DURATION * 2)
     .removeClass('page-header')
     .addClass('jumbotron')
     .velocity('fadeIn', DURATION * 2)
  $.Velocity $('footer').get(0), 'transition.expandIn',
    duration: DURATION


dreamhorn.dispatcher.on "reduce:title", ($el) ->
  container = $el.parent()
  container.height $el.outerHeight(true)
  el = $el.get 0
  $.Velocity(el, 'transition.expandOut', {visibility: "hidden", duration: DURATION / 2})
    .then ->
      $el.removeClass 'jumbotron'
         .addClass 'page-header'
      $.Velocity(el, 'transition.expandIn', {visibility: "visible", duration: DURATION / 2})
        .then ->
          $.Velocity(container, {'height': $el.height()}, {duration: DURATION / 2})
            .then ->
              container.height('auto')
  $.Velocity $('footer').get(0), 'transition.expandOut',
    duration: DURATION


dreamhorn.dispatcher.on "show:begin-button", ($el) ->
  $el.velocity(
    'transition.expandIn',
    {visibility: "visible", duration: DURATION, delay: 100})


dreamhorn.dispatcher.on "remove:begin-button", ($el) ->
  $.Velocity($el.get(0), 'transition.expandOut', {duration: DURATION / 2}).then ->
    $el.remove()


dreamhorn.dispatcher.on "show:situation", ($el, $trigger) ->
  make_invisible($el)
  # $el.velocity('transition.enter', {duration: DURATION * 3})
  sequence = [
    {
      e: $el, p: {height: 0},
      o: {display: 'block', visibility: 'hidden', duration: 0}},
    {
      e: $el, p: {height: '100%'},
      o: {duration: DURATION / 3}},
    {
      e: $el, p: 'scroll',
      o: {duration: DURATION, sequenceQueue: false}},
    {
      e: $el, p: 'transition.bounceLeftIn',
      o: {visibility: "visible", duration: DURATION, sequenceQueue: false}},
  ]
  $.Velocity.RunSequence(sequence)


dreamhorn.dispatcher.on "remove:situation", ($el, $trigger) ->
  sequence = [
    {
      e: $el, p: 'transition.bounceRightOut',
      o: {visibility: "hidden", display: null, duration: DURATION}
      },
    {
      e: $el, p: {height: 0},
      o: {display: "none", duration: DURATION}
      },
  ]
  $.Velocity.RunSequence(sequence)
