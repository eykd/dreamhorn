'use strict';

_ = require('lodash')
ramjet = require('ramjet')

dreamhorn = require('./dreamhorn')

DURATION = 250

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
  $el.velocity('fadeOut', DURATION)
     .removeClass('page-header')
     .addClass('jumbotron')
     .velocity('fadeIn', DURATION)


dreamhorn.dispatcher.on "reduce:title", ($el) ->
  el = $el.get 0
  $.Velocity(el, 'transition.expandOut', {visibility: "hidden", duration: DURATION})
    .then ->
      $el.removeClass 'jumbotron'
         .addClass 'page-header'
         .velocity('transition.expandIn', {visibility: "visible", duration: DURATION})


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
      o: {duration: DURATION}},
    {
      e: $el, p: 'transition.expandIn',
      o: {visibility: "visible", duration: DURATION, delay: DURATION}},
    {
      e: $el, p: 'scroll',
      o: {duration: DURATION}},
  ]
  $.Velocity.RunSequence(sequence)


dreamhorn.dispatcher.on "remove:situation", ($el, $trigger) ->
  $prev = $el.prev()
  sequence = [
    {e: $el, p: 'transition.expandOut', o: {visibility: "hidden", display: null, duration: DURATION}},
    {e: $el, p: {height: 0}, o: {display: "none", duration: DURATION}},
  ]
  if $prev.length
    console.log "Will scroll to previous el first!", $el, $prev
    sequence.unshift {e: $prev, p: 'scroll', o: {duration: DURATION}}
  console.log sequence
  $.Velocity.RunSequence(sequence)
